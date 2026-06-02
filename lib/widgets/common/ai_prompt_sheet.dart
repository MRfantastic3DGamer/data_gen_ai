import 'package:flutter/material.dart';

class AIPromptSheet extends StatefulWidget {
  const AIPromptSheet({super.key, required this.title, required this.onSubmit});

  final String title;
  final ValueChanged<String> onSubmit;

  @override
  State<AIPromptSheet> createState() => _AIPromptSheetState();
}

class _AIPromptSheetState extends State<AIPromptSheet> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(widget.title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              TextField(
                controller: _controller,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Describe what you want to generate or modify...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () {
                  widget.onSubmit(_controller.text.trim());
                  Navigator.of(context).pop();
                },
                child: const Text('Run AI'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
