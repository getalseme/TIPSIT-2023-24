import 'package:floor/floor.dart';

@Entity(tableName: 'post')
class Post {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  final String title;
  final String body;

  Post(this.id, this.title, this.body);
}

@Entity(
  tableName: 'comment',
  foreignKeys: [
    ForeignKey(
      childColumns: ['postId'],
      parentColumns: ['id'],
      entity: Post,
    )
  ]
)
class Comment {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  final String text;
  
  final int postId;

  Comment(this.id, this.text, this.postId);
}

@dao
abstract class PostDao {
  @Query('SELECT * FROM Post')
  Future<List<Post>> findAllPosts();

  @insert
  Future<void> insertPost(Post post);

  @delete 
  Future<void> deletePost(Post post);
}

@dao
abstract class CommentDao {
  @Query('SELECT * FROM Comment WHERE postId = :postId')
  Future<List<Comment>> findCommentsForPost(int postId);

  @insert
  Future<void> insertComment(Comment comment);

  @delete 
  Future<void> deleteComment(Comment comment);
}

