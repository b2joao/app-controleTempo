import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Controle de Tempo de Brinquedos',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: PlaygroundScreen(),
    );
  }
}

class PlaygroundScreen extends StatefulWidget {
  @override
  _PlaygroundScreenState createState() => _PlaygroundScreenState();
}

class _PlaygroundScreenState extends State<PlaygroundScreen> {
  List<Playtime> playtimes = [];

  @override
  void initState() {
    super.initState();
    _loadPlaytimes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        elevation: 2,
        shadowColor: Colors.black,
        title: const Text('Controle de Tempo'),
      ),
      body: ListView.builder(
        itemCount: playtimes.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                        '${playtimes[index].text} - ${playtimes[index].minutes} minutos'),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            setState(() {
                              playtimes[index].minutes += 5;
                              playtimes[index].timer._remainingTime += 5 * 60;
                              _savePlaytimes(); // Salvar ao adicionar tempo
                            });
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            setState(() {
                              playtimes.removeAt(index);
                              _savePlaytimes(); // Salvar ao deletar
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Tempo corrido:'),
                    CountdownTimer(playtime: playtimes[index]),
                  ],
                ),
                const Divider(
                  color: Colors.black38,
                )
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber,
        onPressed: () {
          _showAddPlaytimeDialog(context);
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  void _showAddPlaytimeDialog(BuildContext context) {
    TextEditingController textController = TextEditingController();
    TextEditingController minutesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Adicionar Tempo de Brinquedo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: textController,
                decoration: const InputDecoration(labelText: 'Criança'),
              ),
              TextField(
                controller: minutesController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Tempo'),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  playtimes.add(Playtime(
                    text: textController.text,
                    minutes: int.parse(minutesController.text),
                  ));
                  _savePlaytimes(); // Salvar ao adicionar novo brinquedo
                });
                Navigator.pop(context);
              },
              child: const Text('Adicionar'),
            ),
          ],
        );
      },
    );
  }

  void _savePlaytimes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> playtimesList = playtimes
        .map((playtime) => "${playtime.text}:${playtime.minutes}")
        .toList();
    await prefs.setStringList('playtimes', playtimesList);
  }

  void _loadPlaytimes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? playtimesList = prefs.getStringList('playtimes');
    if (playtimesList != null) {
      setState(() {
        playtimes = playtimesList.map((playtime) {
          List<String> parts = playtime.split(':');
          return Playtime(text: parts[0], minutes: int.parse(parts[1]));
        }).toList();
      });
    }
  }
}

class Playtime {
  String text;
  int minutes;
  late _CountdownTimerState timer;

  Playtime({required this.text, required this.minutes});
}

class CountdownTimer extends StatefulWidget {
  final Playtime playtime;

  CountdownTimer({required this.playtime});

  @override
  _CountdownTimerState createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  late int _remainingTime;
  final Color _textColor = Colors.black;

  @override
  void initState() {
    super.initState();
    _remainingTime = widget.playtime.minutes * 60;
    widget.playtime.timer = this;
    _startTimer();
  }

  void _startTimer() {
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        if (_remainingTime > 0) {
          _remainingTime--;

          if (_remainingTime == 60) {}
        }
      });
      _startTimer();
    });
  }

  @override
  Widget build(BuildContext context) {
    int minutes = _remainingTime ~/ 60;
    int seconds = _remainingTime % 60;
    String formattedTime = '$minutes:${seconds.toString().padLeft(2, '0')}';
    return Text(
      formattedTime,
      style: TextStyle(color: _textColor),
    );
  }
}
