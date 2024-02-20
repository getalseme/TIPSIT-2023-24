import 'package:flutter/material.dart';
import 'database.dart';
import 'models.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = await $FloorMyAppDatabase.databaseBuilder('my_database.db').build();
  runApp(MyApp(database: database));
}

class MyApp extends StatelessWidget {
  final MyAppDatabase database;

  const MyApp({Key? key, required this.database}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Floor Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(database: database),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final MyAppDatabase database;

  const MyHomePage({Key? key, required this.database}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class AddPostForm extends StatefulWidget {
  final MyAppDatabase database;

  const AddPostForm({Key? key, required this.database}) : super(key: key);

  @override
  _AddPostFormState createState() => _AddPostFormState();
}

class _AddPostFormState extends State<AddPostForm> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Post'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            decoration: InputDecoration(labelText: 'Title'),
          ),
          TextField(
            controller: _bodyController,
            decoration: InputDecoration(labelText: 'Body'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            final title = _titleController.text;
            final body = _bodyController.text;
            if (title.isNotEmpty && body.isNotEmpty) {
              final newPost = Post(null, title, body); // Pass null for autoincremented ID
              await widget.database.postDao.insertPost(newPost);
              Navigator.of(context).pop(true); // Signal success to parent widget
            } else {
              // Show error message if title or body is empty
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Please enter both title and body.'),
              ));
            }
          },
          child: Text('Add'),
        ),
      ],
    );
  }
}

class AddCommentForm extends StatefulWidget {
  @override
  _AddCommentFormState createState() => _AddCommentFormState();
}

class _AddCommentFormState extends State<AddCommentForm> {
  final TextEditingController _commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Comment'),
      content: TextField(
        controller: _commentController,
        decoration: InputDecoration(labelText: 'Comment'),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final newComment = _commentController.text.trim();
            if (newComment.isNotEmpty) {
              Navigator.of(context).pop(newComment); // Pass the comment to the parent widget
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Please enter a comment.'),
                ),
              );
            }
          },
          child: Text('Add'),
        ),
      ],
    );
  }
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<List<Post>> _postsFuture;

  @override
  void initState() {
    super.initState();
    _postsFuture = widget.database.postDao.findAllPosts();
  }

  Future<void> _addPost() async {
    final success = await showDialog<bool>(
      context: context,
      builder: (context) => AddPostForm(database: widget.database),
    );

    if (success == true) {
      setState(() {
        // Refresh the UI by fetching the posts again
        _postsFuture = widget.database.postDao.findAllPosts();
      });
    }
  }

  void _onPostTapped(Post post) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Opzioni per ${post.title}'),
        content: Text('cosa vuoi fare con questo post?'),
        actions: [
          TextButton(
            onPressed: () async {
              // Add comment logic
              final newComment = await showDialog<String>(
                context: context,
                builder: (context) => AddCommentForm(),
              );
              if (newComment != null && newComment.isNotEmpty) {
                final comment = Comment(null, newComment, post.id!); // Assuming comment has post_id field
                await widget.database.commentDao.insertComment(comment);
                setState(() {
                  // Refresh comments for this post
                  _postsFuture = widget.database.postDao.findAllPosts();
                });
              }
              Navigator.of(context).pop();
            },
            child: Text('Add Comment'),
          ),
          TextButton(
            onPressed: () async {
              // Remove post logic
              Future<List<Comment>> _FUTcomments = widget.database.commentDao.findCommentsForPost(post.id!);
              List<Comment> _comments = await _FUTcomments;
              for(int i = 0; i < _comments.length; i++){
                widget.database.commentDao.deleteComment(_comments.elementAt(i));
              }
              await widget.database.postDao.deletePost(post);
              setState(() {
                _postsFuture = widget.database.postDao.findAllPosts();
              });
              Navigator.of(context).pop();
            },
            child: Text('Remove'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Back'),
          ),
        ],
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Posts and Comments'),
      ),
      body: FutureBuilder<List<Post>>(
        future: _postsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final posts = snapshot.data!;
            return ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                return GestureDetector(
                  onTap: () => _onPostTapped(post),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      elevation: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              post.title,
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8),
                            Text(post.body),
                            SizedBox(height: 16),
                            FutureBuilder<List<Comment>>(
                              future: widget.database.commentDao.findCommentsForPost(post.id ?? 0),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return CircularProgressIndicator();
                                } else if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                } else {
                                  final comments = snapshot.data!;
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: comments
                                        .map((comment) => Text(comment.text))
                                        .toList(),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addPost,
        child: Icon(Icons.add),
      ),
    );
  }
}
