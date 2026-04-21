import 'package:flutter/material.dart';

class SearchBarWidget extends StatelessWidget {
  final ValueNotifier<String> searchNotifier;

  const SearchBarWidget({
    Key? key,
    required this.searchNotifier,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ValueListenableBuilder<String>(
        valueListenable: searchNotifier,
        builder: (context, searchValue, _) {
          return TextField(
            onChanged: (value) {
              searchNotifier.value = value;
            },
            decoration: InputDecoration(
              hintText: 'Search food... ',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: searchValue.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        searchNotifier.value = '';
                      },
                    ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey[200],
            ),
          );
        },
      ),
    );
  }
}
