import 'package:flutter/material.dart';
import 'package:sqf_lite/employee.dart';
import 'db_helper.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<List<Employee>> employees;
  TextEditingController controller = TextEditingController();
  String name;
  int curUserId;

  final _formKey = GlobalKey<FormState>();
  var dbHelper;
  bool isUpdating;

  @override
  void initState() {
    super.initState();
    dbHelper = DBHelper();
    isUpdating = false;
  }

  refreshList() {
    setState(() {
      employees = dbHelper.getEmployee();
    });
  }

  clearname() {
    controller.text = '';
  }

  validate() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      if (isUpdating) {
        Employee e = Employee(id: curUserId,name: name);
        dbHelper.update(e);
        setState(() {
          isUpdating = false;
        });
      } else {
        Employee e = Employee(id:null, name:name);
        dbHelper.save(e);
      }
      clearname();
      refreshList();
    }
  }

  form() {
    return Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            verticalDirection: VerticalDirection.down,
            children: <Widget>[
              TextFormField(
                controller: controller,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (val) => val.length == 0 ? "Enter a name" : null,
                onSaved: (val) => name = val,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  FlatButton(
                      onPressed: validate,
                      child: Text(isUpdating ? "UPDATE" : "ADD")),
                  FlatButton(
                      onPressed: () {
                        setState(() {
                          isUpdating = false;
                        });
                        clearname();
                      },
                      child: Text("Cancel"))
                ],
              )
            ],
          ),
        ));
  }

  SingleChildScrollView dataTable(List<Employee> employees) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: DataTable(
          columns: [
            DataColumn(label: Text("NAME")),
            DataColumn(label: Text("DELETE"))
          ],
          rows: employees
              .map((e) => DataRow(cells: [
                    DataCell(Text(e.name), onTap: () {
                      setState(() {
                        isUpdating = true;
                        curUserId = e.id;
                      });
                      controller.text = e.name;
                    }),
                    DataCell(IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        dbHelper.delete(e.id);
                        refreshList();
                      },
                    ))
                  ]))
              .toList()),
    );
  }

  list() {
    return Expanded(
        child: FutureBuilder(
      future: employees,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return dataTable(snapshot.data);
        }
        if (snapshot.data == null || snapshot.data.length == 0) {
          return Text("No data found");
        }
        return Center(child: CircularProgressIndicator());
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("SQF LITE"),
        ),
        body: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            verticalDirection: VerticalDirection.down,
            children: <Widget>[
              form(),
              list(),
            ],
          ),
        ),
      ),
    );
  }
}
