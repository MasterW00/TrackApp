import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo ;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          // This is the theme of your application.
          //
          // TRY THIS: Try running your application with "flutter run". You'll see
          // the application has a purple toolbar. Then, without quitting the app,
          // try changing the seedColor in the colorScheme below to Colors.green
          // and then invoke "hot reload" (save your changes or press the "hot
          // reload" button in a Flutter-supported IDE, or press "r" if you used
          // the command line to start the app).
          //
          // Notice that the counter didn't reset back to zero; the application
          // state is not lost during the reload. To reset the state, use hot
          // restart instead.
          //
          // This works for code too, not just values: Most code changes can be
          // tested with just a hot reload.
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const MyHomePage(title: 'Keep Track'),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier{
  var username = '\r';
  var db;
  //connect to database
  Future<void> connect() async{  
    db = await mongo.Db.create("******just probably a good idea because i forgot to remove it initally but it might be too late******");
    await db.open();
    print('Connected to the database');
  }
  //createing user
  Future<void> enrollNewUser(String user, String password) async{
    if(db == null){
      await connect();
    }
    int id = user.hashCode;
    await db.collection('users').insert({'_id':id,'username': user,'password': password.hashCode});
    username = user; 
    notifyListeners();
  }
  Future<void> loadUserData() async{
    if(db == null){
      return;
    }
    var userData = await db.collection('user_data').findOne({'username': username});
    if (userData != null){
      tracks = (userData['tracks'] as List).map((track) => Reminder.fromMap(track)).toList();
    }
    notifyListeners();
  }
  //logging in
  Future<void> login(String user, String password) async{
    if(username != '\r'){
      return;
    }
    if(db == null){
      await connect();
    }
    var auth = await db.collection('users').findOne({'username': user});
    if (auth != null) {
      if (auth['password'] == password.hashCode) {
        print('password matches');
        username = user;
      } 
      else {
        print('password does not match');
        username = '\r';
      }
    } 
    else {
      print('user not found');
    }
    notifyListeners();
  }

  //tracks and reminders
  List<Reminder> tracks = [];
  Future <void> saveTrackInfo() async{
    if(db == null){
      return;
    }
    if (tracks.isNotEmpty){
      await db.collection('user_data').update(
        {'username': username},
        {
          '\$set': {
            'tracks': tracks.map((track) => track.toMap()).toList(),
          }
        },
        upsert: true,
       );
    }
  }
  Future<void> deleteUser() async{
    if(db == null){
      return;
    }
    await db.collection('users').remove({'username': username});
    await db.collection('user_data').remove({'username': username});
    username = '\r';
    tracks = [];
    notifyListeners();
  }
  void newReminder(Reminder newReminder){
    tracks.add(newReminder);
    notifyListeners();
  }
  void addTask(Reminder currentReminder, Task newestTask){
    currentReminder.addTask(newestTask);
    notifyListeners();
  }
  Future<void> removeTask(Reminder reminder, Task task) async{
    reminder.tasks.remove(task);
    // await db.collection('user_data').update(
    //   {'username': username},
    //   {
    //     '\$set': {
    //       'tracks': tracks.map((track) => track.toMap()).toList(),
    //     }
    //   },
    //   upsert: true,
    // );
    notifyListeners();
  }
  Reminder? getReminder(Reminder reminder){
    for(Reminder currentReminder in tracks){
      if (reminder == currentReminder){
        return currentReminder;
      }
    }
    return null;
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.
  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //Widget page = CurrentReminders(turner: ({Widget? page}){});
  Widget page = Login(enroll: true);  
  bool home = false;

  void _turnPage({Widget? page}) {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      if(page != null){
        home = false;
        this.page = page;
        return;
      }
      if(home){
        home = false;
        this.page = Creator(turner: _turnPage);
      }
      else{
        home = true;
        this.page = CurrentReminders(turner: _turnPage);
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    IconData icon;
    if(home){
      icon = Icons.add;
    }
    else {
      icon = Icons.arrow_back_ios_new_outlined;
    }
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
        leading: IconButton(
          icon: Icon(Icons.person_rounded),
          onPressed: (){_turnPage(page:Login(enroll: false));},
        ),
      ),
      body: page,
      floatingActionButton: FloatingActionButton(
        onPressed:(){
            appState.saveTrackInfo();
            _turnPage();
          },
        tooltip: 'Add',
        child: Icon(icon),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

//login page
class Login extends StatefulWidget {
  final bool? enroll;
  const Login({super.key, this.enroll});
  

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  late String username;
  late String password;
  late Widget formPrompt;
  @override 
  initState(){
    super.initState();
    formPrompt = widget.enroll == true ? Text('Create New Account') : Text('Welcome back');
  }
  @override
  void didUpdateWidget(Login oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.enroll != widget.enroll) {
      setState(() {
        formPrompt = widget.enroll == true ? Text('Create New Account') : Text('Welcome Back');
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    GlobalKey<FormState> userForm = GlobalKey<FormState>();
    var appState = context.watch<MyAppState>();
    var username = appState.username;
    if(username != '\r'){
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text('Welcome $username', style: Theme.of(context).textTheme.headlineMedium),
            ),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: (){
                        appState.username = '\r';
                        appState.tracks = [];
                        setState(() {
                          formPrompt = widget.enroll == true ? Text('Create New Account') : Text('Login');
                        });
                      },
                      child: Text('Logout'),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: (){
                        appState.deleteUser();
                        setState(() {
                          formPrompt = widget.enroll == true ? Text('Create New Account') : Text('Login');
                        });
                      },
                      child: Text('Delete Account'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    return Form(
        key: userForm,
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              formPrompt,
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextFormField(
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    hintText: 'Username',
                  ),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a username';
                    }
                    return null;
                  },
                  onSaved: (String? newValue){
                    username = newValue!;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextFormField(
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    hintText: 'password',
                  ),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    return null;
                  },
                  onSaved: (String? newValue){
                    password = newValue!;
                  },
                ),
              ),
              ElevatedButton(
                onPressed: ()async{
                  if (userForm.currentState!.validate()) {
                    userForm.currentState!.save();
                    setState(() {
                      if(appState.username == '\r'){
                        formPrompt = Text('Logging in . . .');
                      }
                    });
                    if(widget.enroll == true){
                      await appState.enrollNewUser(username, password);
                    }
                    else{
                      await appState.login(username, password);
                    }
                    if(appState.username != '\r'){
                      await appState.loadUserData();
                    }
                  }
                },
                child: Text('Login'),
              ),
            ],
          ),
                ),
        ),
    );
  }
}

//track start page
class Creator extends StatelessWidget{
  final Function({Widget? page}) turner;
  const Creator({super.key, required this.turner});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    GlobalKey<FormState> unit = GlobalKey<FormState>();
    Reminder newestReminder;
    return Center(
      child: Form(
        key: unit,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                color: Theme.of(context).colorScheme.onSecondary,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('New Track:', style: Theme.of(context).textTheme.labelLarge),
                      TextFormField(
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          hintText: 'Ex. Car',
                        ),
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'Needs a name';
                          }
                          for(Reminder one in appState.tracks){
                            if(value == one.name){
                              return 'Item already exists';
                            }
                          }
                          return null;
                        },
                        onSaved: (String? newValue) =>{
                          newestReminder = Reminder(name: newValue!),
                          appState.newReminder(newestReminder),
                          turner(page: TaskList(reminder: appState.getReminder(newestReminder)!)),
                        }
                      ),
                    ],
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.onSecondary,
                ),
                onPressed: (){
                  if (unit.currentState!.validate()) {
                   unit.currentState!.save();
                  }
                },
                child: Text(
                  'Create',
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//reminder Homepage
class CurrentReminders extends StatelessWidget {
  final Function({Widget? page}) turner;
  const CurrentReminders({super.key, required this.turner});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style1 = theme.textTheme.displaySmall!.copyWith(
        color: theme.colorScheme.primary,

    );
    final style2 = theme.textTheme.bodyMedium!.copyWith(
        color: theme.colorScheme.primary,

    );
    var appState = context.watch<MyAppState>();
    return ListView(
        children: [
          Center(
            child: Column(
              children: [
                for(var reminder in appState.tracks)
                ListTile(
                  tileColor: Theme.of(context).colorScheme.primaryContainer,
                  onTap:(){
                    turner(page: TaskList(reminder: appState.getReminder(reminder)!));
                  },
                  title: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text('${reminder.name[0].toUpperCase()}${reminder.name.substring(1)}', style:style1),
                    )
                  ),
                ),
              ],
            ),
          ),
        ]
    );
  }
}

//reminder object structure
class Reminder {
  late mongo.ObjectId id;
  late final String name;
  List<Task> tasks;

  Reminder({required this.name}): tasks = [], id = mongo.ObjectId();

  void addTask(Task newTask){
    tasks.add(newTask);
  }
  Map<String, dynamic> toMap(){
    return {
      '_id' : id,
      'name': name,
      'tasks': tasks.map((task) => task.toMap()).toList(),
    };
  }
  factory Reminder.fromMap(Map<String, dynamic> map){
    return Reminder(name: map['name'] as String)
      ..id = map['_id'] as mongo.ObjectId
      ..tasks = (map['tasks'] as List).map((task) => Task.fromMap(task)).toList();
  }
}

class Task{
  late mongo.ObjectId id;
  late final String name;
  late final Map<String, dynamic> recurrence;
  late DateTime nextOccurrence;
  late DateTime lastOccurrence;
  
  Task({required this.name}):id = mongo.ObjectId();

  double calculateProgress(){
    final now = DateTime.now();
    final totalDuration = nextOccurrence.difference(lastOccurrence).inDays;
    final elapsedDuration = now.difference(lastOccurrence).inDays;
    return elapsedDuration / totalDuration;
  }
  void completed(){
    int frequency = recurrence['frequency'] as int;
    DateTime now = DateTime.now();
    switch (recurrence['period']) {
      case 'Day':
        nextOccurrence = now.add(Duration(days: frequency));
      case 'Week':
        nextOccurrence = now.add(Duration(days: frequency * 7));
      case 'Month':
        nextOccurrence = DateTime(now.year, now.month + frequency, now.day);
      case 'Year':
        nextOccurrence = DateTime(now.year + frequency, now.month, now.day);
      default:
        nextOccurrence;
    }
    lastOccurrence = now;
  }
  int calculateRemainingDays(){
    return nextOccurrence.difference(DateTime.now()).inDays;
  }
  DateTime calculateLastOccurrence() {
    int frequency = recurrence['frequency'] as int;
    switch (recurrence['period']) {
      case 'Day':
        return nextOccurrence.subtract(Duration(days: frequency));
      case 'Week':
        return nextOccurrence.subtract(Duration(days: frequency * 7));
      case 'Month':
        return DateTime(nextOccurrence.year, nextOccurrence.month - frequency, nextOccurrence.day);
      case 'Year':
        return DateTime(nextOccurrence.year - frequency, nextOccurrence.month, nextOccurrence.day);
      default:
        return nextOccurrence;
    }
  }

  Map<String, dynamic> toMap(){
    return {
      '_id': id,
      'name': name,
      'recurrence': recurrence,
      'nextOccurrence': nextOccurrence.toIso8601String(),
      'lastOccurrence': lastOccurrence.toIso8601String(),
    };
  }
  factory Task.fromMap(Map<String, dynamic> map){
    return Task(name: map['name'] as String)
      ..id = map['_id'] as mongo.ObjectId
      ..recurrence = map['recurrence'] as Map<String, dynamic>
      ..nextOccurrence = DateTime.parse(map['nextOccurrence'] as String)
      ..lastOccurrence = DateTime.parse(map['lastOccurrence'] as String);
  } 
}
//Task view page
class TaskList extends StatefulWidget{
  final Reminder reminder;
  const TaskList({super.key, required this.reminder});

  @override
  State<TaskList> createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  late var recurrence = {'frequency': 0, 'period': ''};
  late Task newestTask;
  late DateTime startDate;
  
  @override
  Widget build(BuildContext context) {
    //var appState = context.watch<MyAppState>();
    GlobalKey<FormState> taskForm = GlobalKey<FormState>();
    var appState = context.watch<MyAppState>();
    return ListView(
      children: [
        Center(
        child:Column(
          children:[
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text('${widget.reminder.name.substring(0,1).toUpperCase()}${widget.reminder.name.substring(1)}', style: Theme.of(context).textTheme.headlineSmall),
            ),
            for(Task task in widget.reminder.tasks)
            ListTile(
              leading: IconButton(
                onPressed: ()=> setState(() {
                  appState.removeTask(widget.reminder, task);
                  //widget.reminder.tasks.remove(task);
                }),
                icon: Icon(Icons.close_rounded),
              ),
              title:  Center(child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(task.name.toUpperCase(), style: Theme.of(context).textTheme.titleLarge),
                  Text('In ${task.calculateRemainingDays()} Days')
                ],
              )),
              trailing: IconButton(
                onPressed: () => setState(() {
                  task.completed();
                }),
                icon: Icon(Icons.check_rounded),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.all(8.0),
                child: LinearProgressIndicator(
                value: task.calculateProgress(),
                ),
              ),
            ),
            Divider(
              height: 1,
            ),
            Form(
              key: taskForm,
              child: Center(
                child: Column(
                  children:[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Remind me:', style: Theme.of(context).textTheme.bodyLarge!.copyWith()),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: TextFormField(
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          hintText: 'Ex. Renew Registration',
                        ),
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'Needs a name';
                          }
                          for(Task one in widget.reminder.tasks){
                            if(value == one.name){
                              return 'Item already exists';
                            }
                          }
                          return null;
                        },
                        onSaved: (String? newValue) =>{
                          newestTask = Task(name: newValue!),
                        }
                      ),
                    ),
                    Row(
                      children:[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Every', style: Theme.of(context).textTheme.headlineMedium!.copyWith()),
                        ),
                        Flexible(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              style: Theme.of(context).textTheme.headlineSmall,
                              initialValue: '1',
                              decoration: InputDecoration(
                                border: UnderlineInputBorder(),
                                hintText: '1',
                              ),
                              validator: (String? value) {
                                if (value == null || value.isEmpty) {
                                  return 'Put at least one';
                                }
                                else if(int.tryParse(value) == null){
                                  return 'Must be a number';
                                }
                                return null;
                              },
                              onSaved: (String? newValue) {
                                recurrence['frequency'] = int.tryParse(newValue!) as Object;        
                              }
                            ),
                          ),
                        ),
                        Flexible(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: DropdownButtonFormField(
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'Select period',
                              ),
                              items:[
                                DropdownMenuItem(
                                  value: 'Day',
                                  child: Text('Day(s)'),
                                ),
                                DropdownMenuItem(
                                  value: 'Month',
                                  child: Text('Month(s)'),
                                ),
                                DropdownMenuItem(
                                  value: 'Year',
                                  child: Text('Year(s)'),
                                ),
                              ],
                              onChanged:(String? newValue){
                                recurrence['period'] = newValue!;
                              },
                              validator: (String? value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select a period';
                                }
                                return null;
                              },
                              onSaved:(String? newValue){
                              }
                            ),
                          ),
                        ),
                      ]
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('starting on:'),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: InputDatePickerFormField(
                          firstDate:DateTime(2000) ,
                          lastDate: DateTime(2100),
                          initialDate: DateTime.now(),
                          onDateSaved: (DateTime newValue) => {
                            startDate = newValue,
                          },
                                              ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.onSecondary,
                      ),
                      onPressed: (){
                        if (taskForm.currentState!.validate()) {
                          taskForm.currentState!.save();
                          setState((){
                            newestTask.recurrence = recurrence;
                            newestTask.nextOccurrence = startDate;
                            newestTask.lastOccurrence = newestTask.calculateLastOccurrence();
                            widget.reminder.addTask(newestTask);});
                            
                          }
                      },
                      child: Text(
                        'Create',
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ]
                )
              )
            )
          ],
         ),
        ),
      ],
    );
  }
}

//example code
class Example extends StatelessWidget {
  const Example({
    super.key,
    required int counter,
  }) : _counter = counter;

  final int _counter;

  @override
  Widget build(BuildContext context) {
    return Center(
      // Center is a layout widget. It takes a single child and positions it
      // in the middle of the parent.
      child: Column(
        // Column is also a layout widget. It takes a list of children and
        // arranges them vertically. By default, it sizes itself to fit its
        // children horizontally, and tries to be as tall as its parent.
        //
        // Column has various properties to control how it sizes itself and
        // how it positions its children. Here we use mainAxisAlignment to
        // center the children vertically; the main axis here is the vertical
        // axis because Columns are vertical (the cross axis would be
        // horizontal).
        //
        // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
        // action in the IDE, or press "p" in the console), to see the
        // wireframe for each widget.
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text(
            'You have pushed the button this many times:',
          ),
          Text(
            'placehold',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ],
      ),
    );
  }
}

class FormExample extends StatefulWidget {
  const FormExample({super.key});

  @override
  State<FormExample> createState() => _FormExampleState();
}

class _FormExampleState extends State<FormExample> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            decoration: const InputDecoration(
              hintText: 'Enter your email',
            ),
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return 'Please enter some text';
              }
              if (!(value.contains('@') || value.contains('.com'))){
                return 'Invalid email address';
              }
              return null;
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: ElevatedButton(
              onPressed: () {
                // Validate will return true if the form is valid, or false if
                // the form is invalid.
                if (_formKey.currentState!.validate()) {

                }
              },
              child: const Text('Submit'),
            ),
          ),
        ],
      ),
    );
  }
}
