import 'package:flutter/material.dart';
import 'package:job_tracker/models/job_application.dart';

class ApplicationCard extends StatelessWidget {
  final JobApplication application;
  final Color cardColor;

  const ApplicationCard(
      {Key? key, required this.application, required this.cardColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Delete application'),
                content: const Text(
                    'Are you sure you want to delete this application?'),
                actions: <Widget>[
                  TextButton(
                    child: const Text('Cancel'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: const Text('Confirm'),
                    onPressed: () {
                      //delete application function here
                      Navigator.of(context).pop;
                    },
                  )
                ],
              );
            });
      },
      child: Card(
          color: cardColor,
          elevation: 4.0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Title: ${application.title}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    'Description: ${application.description}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    'Created at: ${application.createdAt}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ))),
    );
  }
}
