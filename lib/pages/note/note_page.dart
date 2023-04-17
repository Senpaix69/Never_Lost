import 'package:flutter/material.dart';
import 'package:my_timetable/pages/note/add_note_page.dart';
import 'package:my_timetable/services/database.dart';
import 'package:my_timetable/services/note.dart';
import 'package:my_timetable/utils.dart' show emptyWidget;
import 'package:my_timetable/widgets/animate_route.dart'
    show SlideFromBottomTransition, SlideRightRoute;

class NoteList extends StatefulWidget {
  const NoteList({super.key});
  @override
  State<NoteList> createState() => _NoteListState();
}

class _NoteListState extends State<NoteList>
    with SingleTickerProviderStateMixin {
  late final DatabaseService _database;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _database = DatabaseService();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );
    _animationController.forward();
  }

  List<Note> sort({
    required List<Note> notes,
  }) {
    List<Note> sortedNotes = notes.toList();
    sortedNotes.sort((a, b) => b.date.compareTo(a.date));
    return sortedNotes;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.transparent,
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: null,
        child: StreamBuilder(
          stream: _database.allNotes,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done ||
                snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.grey,
                ),
              );
            }
            final notes = snapshot.data!;
            if (notes.isEmpty) {
              return emptyWidget(
                icon: Icons.library_books_outlined,
                message: "Empty Notes",
              );
            }
            return Container(
              decoration: null,
              height: double.infinity,
              width: double.infinity,
              child: myListBuilder(sort(notes: notes)),
            );
          },
        ),
      ),
    );
  }

  ListView myListBuilder(List<Note> notes) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return FadeTransition(
          opacity: _animation,
          child: SlideFromBottomTransition(
            animation: _animation,
            child: Container(
              margin: const EdgeInsets.symmetric(
                vertical: 5.0,
                horizontal: 10.0,
              ),
              decoration: BoxDecoration(
                color: Colors.grey.withAlpha(60),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: ListTile(
                minVerticalPadding: 15.0,
                onTap: () => Navigator.push(
                  context,
                  SlideRightRoute(page: const AddNote(), arguments: note),
                ),
                title: SizedBox(
                  height: 25.0,
                  child: Text(
                    note.title,
                    style: TextStyle(
                      color: Colors.grey[300],
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      note.body.toString().split("\n").join(""),
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14.0,
                      ),
                    ),
                    const SizedBox(height: 6.0),
                    Text(
                      note.date,
                      style: const TextStyle(
                        fontSize: 12.0,
                        color: Colors.grey,
                      ),
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
}
