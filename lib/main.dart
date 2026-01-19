import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:sandbox_project/models/client.dart';
import 'package:sandbox_project/models/host.dart';
import 'package:sandbox_project/models/order.dart';
import 'package:sandbox_project/models/service.dart';
import 'package:sandbox_project/repos/serviceRepo.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: MultiProvider(
        providers: [Provider<ServiceRepo>(create: (_) => ServiceRepo())],
        child: const MyHomePage(title: 'Flutter Demo Home Page'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool stateInitialized = false;
  bool isHost = false;

  Host? host;
  Client? client;

  List<Service> services = [];
  Service? selectedService;
  bool loadingServices = false;

  final List<Client> demoClients = [
    Client(id: 'client1', name: 'Max is Client1'),
    Client(id: 'client2', name: 'Max is Client2'),
  ];

  Future<void> initUser(bool isHost, ServiceRepo serviceRepo) async {
    setState(() {
      stateInitialized = true;
      this.isHost = isHost;
      services = [];
      loadingServices = true;
    });

    final fetched = isHost
        ? await serviceRepo.fetchAllServices()
        : await serviceRepo.fetchServicesByClient(client!);

    if (!mounted) return;
    setState(() {
      services = fetched;
      loadingServices = false;
    });
  }

  Future<void> refreshServices(ServiceRepo serviceRepo) async {
    setState(() {
      loadingServices = true;
    });

    final fetched = isHost
        ? await serviceRepo.fetchAllServices()
        : await serviceRepo.fetchServicesByClient(client!);

    if (!mounted) return;
    setState(() {
      services = fetched;
      loadingServices = false;
    });
  }

  void resetToStart() {
    setState(() {
      stateInitialized = false;
      isHost = false;
      host = null;
      client = null;
      services = [];
      loadingServices = false;
    });
  }

  Future<void> openCreateService(ServiceRepo serviceRepo) async {
    final Host effectiveHost = host ?? Host(id: 'host1', name: 'Max is Host');
    final Client? effectiveClient = isHost ? null : client;

    final created = await Navigator.push<Service>(
      context,
      MaterialPageRoute(
        builder: (_) => CreateServicePage(
          host: effectiveHost,
          clients: demoClients,
          serviceRepo: serviceRepo,
          initialClient: effectiveClient,
        ),
      ),
    );

    if (created == null || !mounted) return;

    await refreshServices(serviceRepo);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Container(
        color: Colors.blueGrey,
        child: Consumer<ServiceRepo>(
          builder: (context, serviceRepo, child) {
            return Center(
              child: stateInitialized
                  ? userPage(context, serviceRepo)
                  : startPage(context, serviceRepo),
            );
          },
        ),
      ),
    );
  }

  Widget startPage(BuildContext context, ServiceRepo serviceRepo) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () async {
                  host = Host(id: 'host1', name: 'Max is Host');
                  await initUser(true, serviceRepo);
                },
                child: const Text('Enter as Host'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () async {
                  client = demoClients[0];
                  await initUser(false, serviceRepo);
                },
                child: const Text('Enter as Client1'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () async {
                  client = demoClients[1];
                  await initUser(false, serviceRepo);
                },
                child: const Text('Enter as Client2'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget userPage(BuildContext context, ServiceRepo serviceRepo) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              TextButton.icon(
                onPressed: resetToStart,
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                label: const Text(
                  'Back',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => refreshServices(serviceRepo),
                icon: const Icon(Icons.refresh, color: Colors.white),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () => openCreateService(serviceRepo),
                icon: const Icon(Icons.add),
                label: const Text('Create Service'),
              ),
              if (selectedService != null)
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      selectedService!.Progress();
                    });
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Toggle Notif'),
                ),
            ],
          ),
        ),
        Text(
          isHost ? 'Host Page' : 'Client Page',
          style: const TextStyle(color: Colors.white, fontSize: 24),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: loadingServices
              ? const Center(child: CircularProgressIndicator())
              : services.isEmpty
              ? const Center(
                  child: Text(
                    'No services found',
                    style: TextStyle(color: Colors.white70),
                  ),
                )
              : ListView.builder(
                  itemCount: services.length,
                  itemBuilder: (context, index) {
                    final service = services[index];
                    return ListTile(
                      title: Text(
                        'Order: ${service.order.orderType} • ${service.order.difficulty} • ${service.order.condition}',
                        style: TextStyle(
                          color: selectedService == service
                              ? Colors.redAccent
                              : Colors.white,
                        ),
                      ),
                      subtitle: Text(
                        '${isHost ? 'Client: ${service.client?.name ?? 'Unknown'}' : 'Host: ${service.host?.name ?? 'Unknown'}'}\nStatus: ${Service.serviceStatus[service.status]}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      onTap: () {
                        if (selectedService == service) {
                          setState(() {
                            selectedService = null;
                          });
                        } else {
                          setState(() {
                            selectedService = service;
                          });
                        }
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class CreateServicePage extends StatefulWidget {
  final Host host;
  final List<Client> clients;
  final ServiceRepo serviceRepo;
  final Client? initialClient;

  const CreateServicePage({
    super.key,
    required this.host,
    required this.clients,
    required this.serviceRepo,
    this.initialClient,
  });

  @override
  State<CreateServicePage> createState() => _CreateServicePageState();
}

class _CreateServicePageState extends State<CreateServicePage> {
  Client? selectedClient;

  String? orderType;
  String? difficulty;
  String? condition;

  bool saving = false;

  @override
  void initState() {
    super.initState();
    selectedClient =
        widget.initialClient ??
        (widget.clients.isNotEmpty ? widget.clients.first : null);
    orderType = ClientOrder.orderTypes.first;
    difficulty = ClientOrder.difficulties.first;
    condition = ClientOrder.conditions.first;
  }

  Future<void> create() async {
    if (selectedClient == null ||
        orderType == null ||
        difficulty == null ||
        condition == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select all fields')));
      return;
    }

    setState(() => saving = true);

    final order = ClientOrder(
      orderType: orderType!,
      difficulty: difficulty!,
      condition: condition!,
    );

    final service = Service(
      order: order,
      client: selectedClient!,
      host: widget.host,
    );

    try {
      await widget.serviceRepo.createService(service);
      if (!mounted) return;
      Navigator.pop<Service>(context, service);
    } catch (e) {
      if (!mounted) return;
      setState(() => saving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to create service: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Service')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<Client>(
              value: selectedClient,
              decoration: const InputDecoration(labelText: 'Client'),
              items: widget.clients
                  .map((c) => DropdownMenuItem(value: c, child: Text(c.name)))
                  .toList(),
              onChanged: (saving || widget.initialClient != null)
                  ? null
                  : (v) => setState(() => selectedClient = v),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: orderType,
              decoration: const InputDecoration(labelText: 'Order Type'),
              items: ClientOrder.orderTypes
                  .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                  .toList(),
              onChanged: saving ? null : (v) => setState(() => orderType = v),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: difficulty,
              decoration: const InputDecoration(labelText: 'Difficulty'),
              items: ClientOrder.difficulties
                  .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                  .toList(),
              onChanged: saving ? null : (v) => setState(() => difficulty = v),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: condition,
              decoration: const InputDecoration(labelText: 'Condition'),
              items: ClientOrder.conditions
                  .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                  .toList(),
              onChanged: saving ? null : (v) => setState(() => condition = v),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: saving ? null : create,
                child: Text(saving ? 'Creating...' : 'Create Service'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
