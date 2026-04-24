import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/iot_provider.dart';
import '../widgets/iot_dashboard.dart';

class IotStatusScreen extends StatefulWidget {
  const IotStatusScreen({super.key});

  @override
  State<IotStatusScreen> createState() => _IotStatusScreenState();
}

class _IotStatusScreenState extends State<IotStatusScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<IotProvider>().fetchStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    // We just return IotDashboard, which internally handles all states:
    // Loading, LandingPage, PendingPage, and Active Dashboard.
    return const IotDashboard();
  }
}
