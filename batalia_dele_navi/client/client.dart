import 'dart:io';
import 'dart:convert';

void main() async{
  Socket socket = await Socket.connect('127.0.0.1', 3000);
  print('connesso al server');

  socket.listen((data) { 
    print(utf8.decode(data).trim());
  });

  stdin.listen((input) { 
    var message = utf8.decode(input).trim();
    socket.write(message);
  });

} 