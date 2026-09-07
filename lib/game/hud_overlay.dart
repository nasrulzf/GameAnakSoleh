import 'package:flutter/material.dart';

import 'game_anak_soleh.dart';

/// Tombol kontrol sentuh: kiri, kanan, dan lompat. Ditumpuk di atas
/// [GameWidget] pada [GameplayScreen].
class HudOverlay extends StatelessWidget {
  const HudOverlay({super.key, required this.game});

  final GameAnakSoleh game;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _HoldButton(
              icon: Icons.arrow_back_rounded,
              onHoldChanged: (held) => game.player.movingLeft = held,
            ),
            const SizedBox(width: 16),
            _HoldButton(
              icon: Icons.arrow_forward_rounded,
              onHoldChanged: (held) => game.player.movingRight = held,
            ),
            const Spacer(),
            _RoundButton(
              icon: Icons.arrow_upward_rounded,
              size: 76,
              onTap: () => game.player.requestJump(),
            ),
          ],
        ),
      ),
    );
  }
}

class _HoldButton extends StatelessWidget {
  const _HoldButton({required this.icon, required this.onHoldChanged});

  final IconData icon;
  final ValueChanged<bool> onHoldChanged;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => onHoldChanged(true),
      onPointerUp: (_) => onHoldChanged(false),
      onPointerCancel: (_) => onHoldChanged(false),
      child: _RoundButton(icon: icon, size: 64, onTap: null),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.icon, required this.size, this.onTap});

  final IconData icon;
  final double size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.85),
          shape: BoxShape.circle,
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
        ),
        child: Icon(icon, size: size * 0.5, color: const Color(0xFF1E3A8A)),
      ),
    );
  }
}
