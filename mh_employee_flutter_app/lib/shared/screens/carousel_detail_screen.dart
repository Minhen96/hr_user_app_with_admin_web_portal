import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'package:mh_employee_app/shared/models/carousel_item.dart';
import '../models/quote_item.dart';
// TODO: These screens don't exist yet, implement or remove
// import 'carousel_editor_screen.dart';
// import 'quote_editor_screen.dart';

class CarouselDetailScreen extends StatefulWidget {
  final List<CarouselItem> items;
  final int initialIndex;
  final String currentUsername;
  final Function(QuoteItem) onSaveQuote;

  const CarouselDetailScreen({
    super.key,
    required this.items,
    required this.initialIndex,
    required this.currentUsername,
    required this.onSaveQuote,
  });

  @override
  _CarouselDetailScreenState createState() => _CarouselDetailScreenState();
}

class _CarouselDetailScreenState extends State<CarouselDetailScreen> {
  late PageController _pageController;
  late int currentIndex;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);

    // Track view and fetch latest data
    _trackViewAndFetchData();
  }

  Future<void> _refreshData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // If the current item is a QuoteItem, fetch the latest quote data
      if (widget.items[currentIndex] is QuoteItem) {
        final quoteItem = widget.items[currentIndex] as QuoteItem;

        // Fetch the latest quote data
        // TODO: Migrate to ApiClient
        final updatedQuote = await ApiService.getQuote();
        if (updatedQuote != null) {
          setState(() {
            final index = widget.items.indexWhere((item) => item is QuoteItem);
            if (index != -1) {
              widget.items[index] = updatedQuote;
            }
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error refreshing data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to refresh: $e')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _trackViewAndFetchData() async {
    try {
      // Check if current item is a QuoteItem and track view
      if (widget.items[currentIndex] is QuoteItem) {
        final quoteItem = widget.items[currentIndex] as QuoteItem;

        // Auto-track view when reaching the page
        // TODO: Migrate to ApiClient
        await ApiService.addAutoView(quoteItem.id, widget.currentUsername);

        // Fetch the latest quote data
        // TODO: Migrate to ApiClient
        final updatedQuote = await ApiService.getQuote();
        if (updatedQuote != null) {
          setState(() {
            final index = widget.items.indexWhere((item) => item is QuoteItem);
            if (index != -1) {
              widget.items[index] = updatedQuote;
            }
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error tracking view and fetching data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _addReaction(String reaction) async {
    try {
      final quoteItem = widget.items[currentIndex] as QuoteItem;

      // TODO: Migrate to ApiClient - 

      // TODO: Migrate to ApiClient
      await ApiService.addReaction(
        quoteItem.id,
        widget.currentUsername,
        reaction,
      );

      // Fetch the latest quote data
      // TODO: Migrate to ApiClient
      final updatedQuote = await ApiService.getQuote();

      if (updatedQuote != null) {
        setState(() {
          final index = widget.items.indexWhere((item) => item is QuoteItem);
          if (index != -1) {
            widget.items[index] = updatedQuote;
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reaction added successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add reaction: $e')),
      );
    }
  }

  void _openEditor(BuildContext context, CarouselItem item) {
    // TODO: Implement editor screens (QuoteEditorScreen and CarouselEditorScreen)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Editor feature not yet implemented')),
    );
    /*
    if (item is QuoteItem) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QuoteEditorScreen(
            quoteItem: item,
            currentUsername: widget.currentUsername,
            onSave: (updatedQuote) async {
              // TODO: Migrate to ApiClient
              await ApiService.addAutoView(updatedQuote.id, widget.currentUsername);
              widget.onSaveQuote(updatedQuote);
              setState(() {
                final index = widget.items.indexWhere((item) => item is QuoteItem);
                if (index != -1) {
                  widget.items[index] = updatedQuote;
                }
              });
            },
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CarouselEditorScreen(
            carouselItem: item,
            currentUsername: widget.currentUsername,
            onSave: (updatedItem) {
              setState(() {
                final index = widget.items.indexWhere((i) => i.id == item.id);
                if (index != -1) {
                  widget.items[index] = updatedItem;
                }
              });
            },
          ),
        ),
      );
    }
    */
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () => _openEditor(
              context,
              widget.items[currentIndex],
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: Colors.white,
        backgroundColor: Colors.black.withOpacity(0.7),
        child: PageView.builder(
          controller: _pageController,
          itemCount: widget.items.length,
          onPageChanged: (index) {
            setState(() {
              currentIndex = index;
            });
          },
          itemBuilder: (context, index) {
            final item = widget.items[index];
            return _buildCarouselItemDetail(context, item);
          },
        ),
      ),
    );
  }

  Widget _buildCarouselItemDetail(BuildContext context, CarouselItem item) {
    return Stack(
      children: [
        // Background Image
        Hero(
          tag: 'carousel_${item.title}',
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(item.imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        // Gradient Overlay
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.5),
                Colors.black.withOpacity(0.8),
              ],
            ),
          ),
        ),
        // Foreground Content
        SafeArea(
          child: Stack(
            children: [
              // Title Section at the Top
              Positioned(
                top: 20.0,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 10.0,
                            color: Colors.black54,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.titleCn,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              // Content Section at Exact Center
              Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // Prevent stretching
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          item.description,
                          style: const TextStyle(
                            fontSize: 19,
                            color: Colors.white,
                            height: 1.6,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          item.descriptionCn,
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            height: 1.6,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Quick Reaction Section at the Bottom
              if (item is QuoteItem)
                Positioned(
                  bottom: 20.0,
                  left: 16.0,
                  right: 16.0,
                  child: _buildQuickReactions(context, item),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickReactions(BuildContext context, QuoteItem quote) {
    const availableReactions = ['👍', '❤️', '😊', '🎉', '👏'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Reactions:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: availableReactions.map((emoji) {
            return ActionChip(
              backgroundColor: Colors.white.withOpacity(0.2),
              label: Text(
                emoji,
                style: const TextStyle(fontSize: 20),
              ),
              onPressed: () => _addReaction(emoji),
            );
          }).toList(),
        ),
      ],
    );
  }
}


