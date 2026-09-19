import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'game_anak_soleh.dart';

/// Tombol kontrol sentuh (kiri, kanan, lompat) + indikator heart & countdown
/// timer bonus. Ditumpuk di atas [GameWidget] pada [GameplayScreen].
class HudOverlay extends StatelessWidget {
  const HudOverlay({super.key, required this.game});

  final GameAnakSoleh game;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _HeartsIndicator(hearts: game.hearts),
                const Spacer(),
                _TimerIndicator(remainingSeconds: game.remainingSeconds),
              ],
            ),
            const Spacer(),
            Row(
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
          ],
        ),
      ),
    );
  }
}

/// 5 ikon hati merepresentasikan nyawa pemain untuk attempt saat ini (lihan
/// GameAnakSoleh.hearts, direset ke 5 tiap level dimulai/diulang).
class _HeartsIndicator extends StatelessWidget {
  const _HeartsIndicator({required this.hearts});

  final ValueListenable<int> hearts;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: hearts,
      builder: (context, value, _) {
        return Row(
          children: [
            for (var i = 0; i < 5; i++)
              Icon(
                i < value ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: const Color(0xFFEF4444),
                size: 28,
              ),
          ],
        );
      },
    );
  }
}

/// Countdown bonus waktu, hanya tampil untuk level yang punya
/// `timeLimitSeconds` (Episode 4 & 5). Waktu habis tidak menggagalkan level
/// — hanya berubah warna abu-abu menandakan bonus skor sudah hilang.
class _TimerIndicator extends StatelessWidget {
  const _TimerIndicator({required this.remainingSeconds});

  final ValueListenable<int?> remainingSeconds;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int?>(
      valueListenable: remainingSeconds,
      builder: (context, value, _) {
        if (value == null) return const SizedBox.shrink();
        final expired = value <= 0;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.timer_rounded,
                size: 20,
                color: expired ? Colors.grey : const Color(0xFF1E3A8A),
              ),
              const SizedBox(width: 6),
              Text(
                '${value}s',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: expired ? Colors.grey : const Color(0xFF1E3A8A),
                ),
              ),
            ],
          ),
        );
      },
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
