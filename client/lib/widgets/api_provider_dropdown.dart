import 'package:flutter/material.dart';

import '../api/api_provider.dart';

class ApiProviderDropdown extends StatelessWidget {
  const ApiProviderDropdown({
    super.key,
    required this.selectedProvider,
    required this.providers,
    required this.onChanged,
  });

  final ApiProviderOption selectedProvider;
  final List<ApiProviderOption> providers;
  final ValueChanged<ApiProviderOption> onChanged;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 10, right: 4),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<ApiProviderOption>(
            value: selectedProvider,
            dropdownColor: const Color(0xff111111),
            iconEnabledColor: Colors.white,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
            items: [
              for (final provider in providers)
                DropdownMenuItem(value: provider, child: Text(provider.label)),
            ],
            selectedItemBuilder: (context) => [
              for (final provider in providers)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('API'),
                    const SizedBox(width: 6),
                    Text(provider.label),
                  ],
                ),
            ],
            onChanged: (provider) {
              if (provider != null) onChanged(provider);
            },
          ),
        ),
      ),
    );
  }
}
