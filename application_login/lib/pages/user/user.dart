import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/theme_app.dart';
import '../../services/api_service.dart';

class UserScreen extends StatefulWidget {
  final String username;
  final String token;

  const UserScreen({
    super.key,
    required this.username,
    required this.token,
  });

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<UserStatus> _statuses = [];

  @override
  void initState() {
    super.initState();
    _fetchStatuses();
  }

  Future<void> _fetchStatuses() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final result = await ApiService.getUserStatuses(widget.token);
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      if (result.ok) {
        _statuses = result.data as List<UserStatus>;
      } else {
        _errorMessage = result.error;
      }
    });
  }

  // ──────────────────────────────────────────
  // Crear nuevo estado de usuario
  // ──────────────────────────────────────────

  void _showAddStatusDialog() {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.add_circle_outline, color: AppTheme.primary),
            const SizedBox(width: 8),
            Text(
              'Nuevo Estado',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: 'Descripción'),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Requerido' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              Navigator.pop(ctx);

              final result = await ApiService.addUserStatus(
                token: widget.token,
                name: nameCtrl.text.trim(),
                description: descCtrl.text.trim(),
              );

              if (!mounted) return;
              _showSnack(
                result.ok ? 'Estado registrado ✅' : result.error ?? 'Error',
                result.ok ? Colors.green : Colors.red,
              );
              if (result.ok) _fetchStatuses();
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  // ──────────────────────────────────────────
  // UI
  // ──────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          // Encabezado con botón Nuevo
          Row(
            children: [
              Text(
                'Estados de Usuario',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2D2D2D),
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: _fetchStatuses,
                icon: const Icon(Icons.refresh_rounded),
                tooltip: 'Recargar',
                color: AppTheme.primary,
              ),
              FilledButton.icon(
                onPressed: _showAddStatusDialog,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Nuevo'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Lista de estados
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_errorMessage != null)
            Card(
              color: Colors.red.shade50,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const Icon(Icons.error_outline_rounded,
                        color: Colors.redAccent, size: 36),
                    const SizedBox(height: 8),
                    Text(_errorMessage!,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(color: Colors.redAccent)),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: _fetchStatuses,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Reintentar'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (_statuses.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  'No hay estados disponibles.',
                  style: GoogleFonts.poppins(color: Colors.grey),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _statuses.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final s = _statuses[index];
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Card(
                    margin: EdgeInsets.zero,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      leading: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            '${s.id}',
                            style: GoogleFonts.poppins(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                      title: Text(
                        s.name,
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        s.description,
                        style: GoogleFonts.poppins(fontSize: 12),
                      ),
                    ),
                  ),
                );
              },
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
