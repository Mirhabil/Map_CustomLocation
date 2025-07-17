import 'package:flutter/material.dart';
import 'package:map_project/Search_Screen.dart';

List<Map<String, String>> listOfLocations = [
  {"Baku": "Azerbaijan"},
];

late String myCustomLocationName;

class AddLocationScreen extends StatefulWidget {
  const AddLocationScreen({super.key});

  @override
  State<AddLocationScreen> createState() => _AddLocationScreenState();
}

class _AddLocationScreenState extends State<AddLocationScreen> {
  final TextEditingController _textController = TextEditingController();

  void _showAddLocationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Enter Location Name"),
          content: TextField(
            controller: _textController,
            decoration: InputDecoration(hintText: "e.g. Ganja"),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                myCustomLocationName = _textController.text;
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SearchScreen()),
                );
                //final text = _textController.text.trim();
                // if (text.isNotEmpty) {
                //   setState(() {
                //     listOfLocations.add({"name": text});
                //   });
                //   _textController.clear(); // reset field
                //   Navigator.pop(context); // close dialog
                // }
              },
              child: Text("Add Location"),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              separatorBuilder:
                  (context, index) => Divider(
                    color: Colors.grey,
                    thickness: 1,
                    indent: 16,
                    endIndent: 16,
                  ),
              itemCount: listOfLocations.length,
              itemBuilder: (context, index) {
                final entry = listOfLocations[index].entries.first;
                return ListTile(
                  leading: Icon(Icons.location_on),
                  title: Text(entry.key),
                  subtitle: Text(entry.value),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: _showAddLocationDialog,
            child: Text("Add Location"),
          ),
          SizedBox(height: 60),
        ],
      ),
    );
  }
}
