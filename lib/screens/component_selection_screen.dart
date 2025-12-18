import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/component.dart';
import '../providers/build_provider.dart';

class ComponentSelectionScreen extends ConsumerWidget {
  final ComponentType componentType;

  const ComponentSelectionScreen({super.key, required this.componentType});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // In a real app, this would come from a repository/API
    final components = _getMockComponents(componentType);

    return Scaffold(
      appBar: AppBar(title: Text('Select ${componentType.name.toUpperCase()}')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: components.length,
        itemBuilder: (context, index) {
          final component = components[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Text(
                component.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(component.brand),
                  const SizedBox(height: 4),
                  // Simple specs display
                  ...component.specs.entries.map(
                    (e) => Text(
                      '${e.key}: ${e.value}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                ],
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    component.priceFormatted,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.greenAccent,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    child: const Icon(Icons.add, color: Colors.blueAccent),
                    onTap: () {
                      ref
                          .read(buildProvider.notifier)
                          .selectComponent(component);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              onTap: () {
                ref.read(buildProvider.notifier).selectComponent(component);
                Navigator.pop(context);
              },
            ),
          );
        },
      ),
    );
  }

  // Temporary mock data generator
  List<Component> _getMockComponents(ComponentType type) {
    switch (type) {
      case ComponentType.cpu:
        return [
          const Component(
            id: 'c1',
            name: 'Core i9-13900K',
            brand: 'Intel',
            type: ComponentType.cpu,
            price: 589.99,
            specs: {'Cores': '24', 'Threads': '32', 'Socket': 'LGA1700'},
          ),
          const Component(
            id: 'c2',
            name: 'Ryzen 9 7950X',
            brand: 'AMD',
            type: ComponentType.cpu,
            price: 559.00,
            specs: {'Cores': '16', 'Threads': '32', 'Socket': 'AM5'},
          ),
          const Component(
            id: 'c3',
            name: 'Core i5-13600K',
            brand: 'Intel',
            type: ComponentType.cpu,
            price: 319.99,
            specs: {'Cores': '14', 'Threads': '20', 'Socket': 'LGA1700'},
          ),
        ];
      case ComponentType.gpu:
        return [
          const Component(
            id: 'g1',
            name: 'GeForce RTX 4090',
            brand: 'NVIDIA',
            type: ComponentType.gpu,
            price: 1599.99,
            specs: {'VRAM': '24GB', 'Clock': '2.52 GHz'},
          ),
          const Component(
            id: 'g2',
            name: 'Radeon RX 7900 XTX',
            brand: 'AMD',
            type: ComponentType.gpu,
            price: 999.99,
            specs: {'VRAM': '24GB', 'Clock': '2.50 GHz'},
          ),
          const Component(
            id: 'g3',
            name: 'GeForce RTX 4070',
            brand: 'NVIDIA',
            type: ComponentType.gpu,
            price: 599.99,
            specs: {'VRAM': '12GB', 'Clock': '2.48 GHz'},
          ),
        ];
      case ComponentType.ram:
        return [
          const Component(
            id: 'r1',
            name: 'Vengeance 32GB (2x16GB) DDR5',
            brand: 'Corsair',
            type: ComponentType.ram,
            price: 149.99,
            specs: {'Speed': '6000MHz', 'Latency': 'CL36'},
          ),
          const Component(
            id: 'r2',
            name: 'Trident Z5 32GB (2x16GB) DDR5',
            brand: 'G.Skill',
            type: ComponentType.ram,
            price: 169.99,
            specs: {'Speed': '6400MHz', 'Latency': 'CL32'},
          ),
        ];
      case ComponentType.motherboard:
        return [
          const Component(
            id: 'm1',
            name: 'Z790 AORUS ELITE',
            brand: 'Gigabyte',
            type: ComponentType.motherboard,
            price: 259.99,
            specs: {'Socket': 'LGA1700', 'Form Factor': 'ATX'},
          ),
          const Component(
            id: 'm2',
            name: 'ROG STRIX B650E-F',
            brand: 'ASUS',
            type: ComponentType.motherboard,
            price: 299.99,
            specs: {'Socket': 'AM5', 'Form Factor': 'ATX'},
          ),
        ];
      default:
        return [
          Component(
            id: 'x1',
            name: 'Generic ${type.name} Item',
            brand: 'Generic',
            type: type,
            price: 99.99,
            specs: {'Note': 'Placeholder item'},
          ),
        ];
    }
  }
}
