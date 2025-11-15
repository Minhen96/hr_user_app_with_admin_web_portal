import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mh_employee_app/shared/models/message_board_item.dart';

class MessageBoardCarousel extends StatefulWidget {
  final MessageBoardItem? currentMessage;
  final Function(String) onSubmit;

  const MessageBoardCarousel({
    Key? key,
    this.currentMessage,
    required this.onSubmit,
  }) : super(key: key);

  @override
  _MessageBoardCarouselState createState() => _MessageBoardCarouselState();
}

class _MessageBoardCarouselState extends State<MessageBoardCarousel> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.currentMessage != null) ...[
                Text(
                  widget.currentMessage!.message,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'Posted by ${widget.currentMessage!.author} on ${DateFormat('MMM dd, yyyy').format(widget.currentMessage!.datePosted)}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Share your thoughts...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      if (_controller.text.isNotEmpty) {
                        widget.onSubmit(_controller.text);
                        _controller.clear();
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

