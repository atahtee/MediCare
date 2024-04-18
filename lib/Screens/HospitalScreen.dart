import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:medicare/Screens/MapScreen.dart';

class HospitalScreen extends StatefulWidget {
  const HospitalScreen({Key? key}) : super(key: key);

  @override
  _HospitalScreenState createState() => _HospitalScreenState();
}

class _HospitalScreenState extends State<HospitalScreen> {
  TextEditingController _searchController = TextEditingController();
  List<dynamic> _hospitalData = [];
  List<dynamic> _filteredHospitals = [];
  dynamic _selectedHospital;
  @override
  void initState() {
    super.initState();
    fetchHospitals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Find Hospitals'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search for a hospital/location',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  onPressed: _clearSearch,
                  icon: Icon(Icons.clear),
                ),
              ),
              onChanged: _onSearchChanged,
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredHospitals.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_filteredHospitals[index]["name"]),
                    onTap: () {
                      setState(() {
                        _selectedHospital = _filteredHospitals[index];
                      });
                      _showHospitalDetails(context);
                    },
                  );
                },
              ),
            ),
            if (_selectedHospital !=
                null) // This only shows a card if a hospital is selected
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: _buildHospitalDetailsCard(context),
              ),
          ],
        ),
      ),
    );
  }

  void _onSearchChanged(String value) {
    setState(() {
      _filteredHospitals = _hospitalData
          .where((hospital) =>
              hospital["name"].toLowerCase().contains(value.toLowerCase()))
          .toList();
    });
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _filteredHospitals = _hospitalData;
      _selectedHospital = null; // Clear selection
    });
  }

//This is the function to fetch hospitals
  Future<void> fetchHospitals() async {
  try {
    final response = await http.get(
      Uri.parse("https://medicareapi-dy09.onrender.com/getHospitals"),
    );
    if (response.statusCode == 200) {
      setState(() {
        _hospitalData = json.decode(response.body);
        _filteredHospitals = _hospitalData;
      });
    } else {
      // This handles unsuccessful response (not a 200 status code)
      throw Exception('Failed to load hospitals: ${response.statusCode}');
    }
  } on Exception catch (e) {
    // Handle any other exceptions (e.g., network errors)
    showErrorDialog(context, "Error fetching hospitals: $e");
  }
}

void showErrorDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Error'),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Close'),
        ),
      ],
    ),
  );
}

// This builds a card widget displaying detailed information about the selected hospital.
Widget _buildHospitalDetailsCard(BuildContext context) {
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _selectedHospital["name"],
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(_selectedHospital["location"]),
          SizedBox(height: 8),
          Text(_selectedHospital["services"]),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      MapScreen(selectedHospital: _selectedHospital),
                ),
              );
            },
            child: Text('Location'),
          ),
        ],
      ),
    ),
  );
}

//This displays an alert dialog showing details of the selected hospital
void _showHospitalDetails(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(_selectedHospital["name"]),
        content: SingleChildScrollView(
          child: ListBody(
            children: [
              Text("Location: ${_selectedHospital["location"]}"),
              Text("Services: ${_selectedHospital["services"]}"),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
          TextButton(
            onPressed: () {
              // Navigate to MapScreen with the selected hospital's location
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MapScreen(selectedHospital: _selectedHospital),
                ),
              );
            },
            child: Text('Location'),
          ),
        ],
      );
    },
  );
}
}
