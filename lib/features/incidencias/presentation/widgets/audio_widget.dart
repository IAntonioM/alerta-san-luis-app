import 'package:flutter/material.dart';
import '../../../../utils/responsive_helper.dart';

enum AudioState { idle, recording, paused, recorded, playing }

class AudioWidget extends StatefulWidget {
  final String? audioPath;
  final Function(String?) onAudioRecorded;

  const AudioWidget({
    super.key,
    required this.audioPath,
    required this.onAudioRecorded,
  });

  @override
  State<AudioWidget> createState() => _AudioWidgetState();
}

class _AudioWidgetState extends State<AudioWidget>
    with TickerProviderStateMixin {
  AudioState _audioState = AudioState.idle;
  Duration _recordingDuration = Duration.zero;
  Duration _playbackDuration = Duration.zero;
  Duration _totalDuration = Duration.zero;
  
  late AnimationController _pulseController;
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    if (widget.audioPath != null) {
      _audioState = AudioState.recorded;
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  void _startRecording() {
    setState(() {
      _audioState = AudioState.recording;
      _recordingDuration = Duration.zero;
    });
    _pulseController.repeat();
    _waveController.repeat();
    
    // TODO: Implementar lógica de grabación de audio
    // Aquí deberías integrar con un paquete como audio_recorder o similar
  }

  void _pauseRecording() {
    setState(() {
      _audioState = AudioState.paused;
    });
    _pulseController.stop();
    _waveController.stop();
    
    // TODO: Pausar grabación de audio
  }

  void _stopRecording() {
    setState(() {
      _audioState = AudioState.recorded;
    });
    _pulseController.stop();
    _waveController.stop();
    
    // TODO: Finalizar grabación y obtener el path del archivo
    // Por ahora simulamos un path de archivo
    const String simulatedPath = '/path/to/recorded_audio.m4a';
    widget.onAudioRecorded(simulatedPath);
  }

  void _playAudio() {
    setState(() {
      _audioState = AudioState.playing;
      _playbackDuration = Duration.zero;
    });
    _waveController.repeat();
    
    // TODO: Reproducir audio
    // Simular reproducción por 3 segundos
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _audioState = AudioState.recorded;
        });
        _waveController.stop();
      }
    });
  }

  void _deleteAudio() {
    setState(() {
      _audioState = AudioState.idle;
      _recordingDuration = Duration.zero;
      _playbackDuration = Duration.zero;
      _totalDuration = Duration.zero;
    });
    widget.onAudioRecorded(null);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Audio de evidencia',
          style: TextStyle(
            fontSize: ResponsiveHelper.getTitleFontSize(context, base: 18),
            fontWeight: FontWeight.w500,
            color: const Color(0xFF333333),
          ),
        ),
        SizedBox(height: ResponsiveHelper.getFormFieldSpacing(context)),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(
            ResponsiveHelper.getSpacing(context, base: 20),
          ),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: ResponsiveHelper.getImageBorderRadius(context),
            border: Border.all(
              color: _audioState != AudioState.idle
                  ? const Color(0xFF1976D2)
                  : Colors.grey.shade300,
              width: _audioState != AudioState.idle ? 2.0 : 1.5,
            ),
          ),
          child: Column(
            children: [
              _buildAudioVisualizer(),
              SizedBox(height: ResponsiveHelper.getSpacing(context, base: 16)),
              _buildAudioControls(),
              if (_audioState != AudioState.idle) ...[
                SizedBox(height: ResponsiveHelper.getSpacing(context, base: 12)),
                _buildDurationInfo(),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAudioVisualizer() {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, child) {
        return Container(
          height: ResponsiveHelper.getSpacing(context, base: 60),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final delay = index * 0.2;
              final animation = Tween<double>(begin: 0.3, end: 1.0).animate(
                CurvedAnimation(
                  parent: _waveController,
                  curve: Interval(delay, 1.0, curve: Curves.easeInOut),
                ),
              );
              
              return AnimatedBuilder(
                animation: animation,
                builder: (context, child) {
                  return Container(
                    width: ResponsiveHelper.getSpacing(context, base: 4),
                    height: ResponsiveHelper.getSpacing(context, base: 30) * 
                           (_audioState == AudioState.recording || 
                            _audioState == AudioState.playing ? animation.value : 0.3),
                    margin: EdgeInsets.symmetric(
                      horizontal: ResponsiveHelper.getSpacing(context, base: 2),
                    ),
                    decoration: BoxDecoration(
                      color: _getVisualizerColor(),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  );
                },
              );
            }),
          ),
        );
      },
    );
  }

  Color _getVisualizerColor() {
    switch (_audioState) {
      case AudioState.recording:
        return Colors.red;
      case AudioState.playing:
        return const Color(0xFF1976D2);
      case AudioState.recorded:
        return Colors.green;
      default:
        return Colors.grey.shade400;
    }
  }

  Widget _buildAudioControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildControlButton(),
        if (_audioState == AudioState.recording) _buildPauseButton(),
        if (_audioState == AudioState.recorded || _audioState == AudioState.playing)
          _buildPlayButton(),
        if (_audioState != AudioState.idle) _buildDeleteButton(),
      ],
    );
  }

  Widget _buildControlButton() {
    IconData icon;
    Color color;
    VoidCallback? onPressed;

    switch (_audioState) {
      case AudioState.idle:
        icon = Icons.mic;
        color = const Color(0xFF1976D2);
        onPressed = _startRecording;
        break;
      case AudioState.recording:
        icon = Icons.stop;
        color = Colors.red;
        onPressed = _stopRecording;
        break;
      case AudioState.paused:
        icon = Icons.fiber_manual_record;
        color = Colors.orange;
        onPressed = _startRecording;
        break;
      default:
        icon = Icons.mic;
        color = const Color(0xFF1976D2);
        onPressed = _startRecording;
    }

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Transform.scale(
          scale: _audioState == AudioState.recording 
              ? 1.0 + (_pulseController.value * 0.1)
              : 1.0,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: _audioState == AudioState.recording
                  ? [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                shape: const CircleBorder(),
                padding: EdgeInsets.all(
                  ResponsiveHelper.getSpacing(context, base: 16),
                ),
                elevation: ResponsiveHelper.getElevation(context, base: 4),
              ),
              child: Icon(
                icon,
                size: ResponsiveHelper.getIconSize(context, base: 24),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPauseButton() {
    return ElevatedButton(
      onPressed: _pauseRecording,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        padding: EdgeInsets.all(
          ResponsiveHelper.getSpacing(context, base: 12),
        ),
      ),
      child: Icon(
        Icons.pause,
        size: ResponsiveHelper.getIconSize(context, base: 20),
      ),
    );
  }

  Widget _buildPlayButton() {
    return ElevatedButton(
      onPressed: _audioState == AudioState.playing ? null : _playAudio,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        padding: EdgeInsets.all(
          ResponsiveHelper.getSpacing(context, base: 12),
        ),
      ),
      child: Icon(
        _audioState == AudioState.playing ? Icons.pause : Icons.play_arrow,
        size: ResponsiveHelper.getIconSize(context, base: 20),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return ElevatedButton(
      onPressed: _deleteAudio,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red.shade400,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        padding: EdgeInsets.all(
          ResponsiveHelper.getSpacing(context, base: 12),
        ),
      ),
      child: Icon(
        Icons.delete,
        size: ResponsiveHelper.getIconSize(context, base: 20),
      ),
    );
  }

  Widget _buildDurationInfo() {
    String durationText;
    switch (_audioState) {
      case AudioState.recording:
      case AudioState.paused:
        durationText = _formatDuration(_recordingDuration);
        break;
      case AudioState.playing:
        durationText = '${_formatDuration(_playbackDuration)} / ${_formatDuration(_totalDuration)}';
        break;
      case AudioState.recorded:
        durationText = _formatDuration(_totalDuration);
        break;
      default:
        durationText = '00:00';
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          _audioState == AudioState.recording 
              ? Icons.fiber_manual_record 
              : Icons.audiotrack,
          size: ResponsiveHelper.getIconSize(context, base: 16),
          color: _getVisualizerColor(),
        ),
        SizedBox(width: ResponsiveHelper.getSpacing(context, base: 8)),
        Text(
          durationText,
          style: TextStyle(
            fontSize: ResponsiveHelper.getBodyFontSize(context, base: 14),
            color: const Color(0xFF666666),
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}