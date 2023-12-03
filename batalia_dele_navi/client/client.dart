import 'dart:io';

late Socket socket;

void main() {
  Socket.connect("localhost", 3000).then((Socket sock) {
    socket = sock;
    socket.listen(dataHandler,
        onError: errorHandler, onDone: doneHandler, cancelOnError: false);
  }, onError: (e) {
    print("Unable to connect: $e");
    exit(1);
  });

  // connect standard in to the socket
  stdin
      .listen((data) => socket.write(String.fromCharCodes(data).trim() + '\n'));
}

void dataHandler(data) {
  print(String.fromCharCodes(data).trim());
}

void errorHandler(error, StackTrace trace) {
  print(error);
}

void doneHandler() {
  socket.destroy();
  exit(0);
}
