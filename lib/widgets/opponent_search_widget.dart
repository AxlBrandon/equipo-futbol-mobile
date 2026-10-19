import 'package:flutter/material.dart';

import '../services/team_search_service.dart';

class OpponentSearchWidget extends StatefulWidget {
  final Function(String opponentName, String badgeUrl) onTeamSelected;

  const OpponentSearchWidget({super.key, required this.onTeamSelected});

  @override
  State<OpponentSearchWidget> createState() => _OpponentSearchWidgetState();
}

class _OpponentSearchWidgetState extends State<OpponentSearchWidget> {
  String selectedName = '';
  String selectedBadge = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Buscar Equipo Contrario',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Autocomplete<TeamSuggestion>(
          displayStringForOption: (TeamSuggestion option) => option.name,
          optionsBuilder: (TextEditingValue textEditingValue) async {
            if (textEditingValue.text.length < 3) {
              return const Iterable<TeamSuggestion>.empty();
            }
            return await TeamSearchService.searchTeams(textEditingValue.text);
          },
          onSelected: (TeamSuggestion selection) {
            setState(() {
              selectedName = selection.name;
              selectedBadge = selection.badgeUrl;
            });
            widget.onTeamSelected(selection.name, selection.badgeUrl);
          },
          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
            return TextField(
              controller: controller,
              focusNode: focusNode,
              decoration: InputDecoration(
                labelText: 'Escribe el nombre del rival (ej. Real Madrid)',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF0077B6)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4.0,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 320,
                  color: Colors.white,
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (BuildContext context, int index) {
                      final TeamSuggestion option = options.elementAt(index);
                      return ListTile(
                        leading: option.badgeUrl.isNotEmpty
                            ? Image.network(
                                option.badgeUrl,
                                width: 32,
                                height: 32,
                                errorBuilder: (_, e, _) =>
                                    const Icon(Icons.shield),
                              )
                            : const Icon(Icons.sports_soccer),
                        title: Text(
                          option.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        onTap: () => onSelected(option),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        if (selectedName.isNotEmpty)
          Row(
            children: [
              if (selectedBadge.isNotEmpty)
                Image.network(
                  selectedBadge,
                  width: 40,
                  height: 40,
                  errorBuilder: (_, e, _) => const Icon(Icons.shield),
                )
              else
                const Icon(Icons.shield, size: 40, color: Color(0xFF0077B6)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Rival seleccionado: $selectedName',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0077B6),
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
