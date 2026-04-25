import 'package:flutter/material.dart';

void main() {
  runApp(HallApp());
}

class HallApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Hall Availability",
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: HallScreen(),
    );
  }
}

class HallScreen extends StatefulWidget {
  @override
  _HallScreenState createState() => _HallScreenState();
}

class _HallScreenState extends State<HallScreen> {
  DateTime selectedDate = DateTime.now();
  String selectedHall = "Assembly Hall";

  List<String> halls = ["Assembly Hall", "Seminar Hall", "Auditorium"];

  Map<String, List<Map<String, dynamic>>> bookings = {};

  TextEditingController nameController = TextEditingController();

  TimeOfDay? startTime;
  TimeOfDay? endTime;

  String getKey() {
    return "${selectedDate.toString().split(' ')[0]}_$selectedHall";
  }

  List<Map<String, dynamic>> getSlots() {
    String key = getKey();
    return bookings[key] ?? [];
  }

  void addBooking() {
    if (nameController.text.isEmpty ||
        startTime == null ||
        endTime == null) return;

    String key = getKey();
    bookings.putIfAbsent(key, () => []);

    setState(() {
      bookings[key]!.add({
        "from": startTime!.format(context),
        "to": endTime!.format(context),
        "by": nameController.text,
      });
    });

    nameController.clear();
    startTime = null;
    endTime = null;

    Navigator.pop(context);
  }

  void deleteBooking(int index) {
    String key = getKey();
    setState(() {
      bookings[key]!.removeAt(index);
    });
  }

  void pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => startTime = picked);
    }
  }

  Future<void> pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => endTime = picked);
    }
  }

  void showBookingDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text("Book Hall"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: "Your Name",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: pickStartTime,
                      child: Text(startTime == null
                          ? "Start"
                          : startTime!.format(context)),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: pickEndTime,
                      child: Text(endTime == null
                          ? "End"
                          : endTime!.format(context)),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: addBooking,
              child: Text("Book"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> currentSlots = getSlots();

    return Scaffold(
      body: Column(
        children: [
          // 🔥 Header
          Container(
            padding: EdgeInsets.fromLTRB(16, 50, 16, 20),
            decoration: BoxDecoration(
              gradient:
                  LinearGradient(colors: [Colors.indigo, Colors.blueAccent]),
              borderRadius:
                  BorderRadius.vertical(bottom: Radius.circular(25)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Hall Availability",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                      style: TextStyle(color: Colors.white),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.indigo,
                      ),
                      onPressed: pickDate,
                      child: Text("Change"),
                    )
                  ],
                ),

                SizedBox(height: 10),

                DropdownButton<String>(
                  value: selectedHall,
                  dropdownColor: Colors.white,
                  isExpanded: true,
                  onChanged: (val) =>
                      setState(() => selectedHall = val!),
                  items: halls
                      .map((h) =>
                          DropdownMenuItem(value: h, child: Text(h)))
                      .toList(),
                ),
              ],
            ),
          ),

          SizedBox(height: 10),

          // 📋 List
          Expanded(
            child: currentSlots.isEmpty
                ? Center(child: Text("No bookings"))
                : ListView.builder(
                    itemCount: currentSlots.length,
                    itemBuilder: (context, index) {
                      final slot = currentSlots[index];

                      return Container(
                        margin: EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 5,
                            )
                          ],
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.indigo,
                              child: Icon(Icons.access_time,
                                  color: Colors.white),
                            ),
                            SizedBox(width: 10),

                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${slot["from"]} - ${slot["to"]}",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    "Booked by ${slot["by"]}",
                                    style: TextStyle(
                                        color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ),

                            IconButton(
                              icon: Icon(Icons.delete,
                                  color: Colors.red),
                              onPressed: () =>
                                  deleteBooking(index),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),

      // ✅ FOOTER
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(10),
        color: Colors.indigo.shade50,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Siddhi Shetkar",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text("160124737160"),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.indigo,
        onPressed: showBookingDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}