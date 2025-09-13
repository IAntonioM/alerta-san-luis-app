import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../utils/responsive_helper.dart';

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

  // flutter_sound instances
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _player = FlutterSoundPlayer();

  // Timers
  Timer? _recordingTimer;
  Timer? _playbackTimer;

  String? _currentAudioPath;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    _initializeAudio();

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
      _currentAudioPath = widget.audioPath;
    }
  }

  Future<void> _initializeAudio() async {
    try {
      await _recorder.openRecorder();
      await _player.openPlayer();
      debugPrint('Audio inicializado correctamente');
    } catch (e) {
      debugPrint('Error inicializando audio: $e');
    }
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _playbackTimer?.cancel();

    _pulseController.dispose();
    _waveController.dispose();

    _recorder.closeRecorder();
    _player.closePlayer();
    super.dispose();
  }

  Future<String> _getAudioPath() async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'audio_${DateTime.now().millisecondsSinceEpoch}.aac';
    return '${directory.path}/$fileName';
  }

  Future<bool> _requestPermissions() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<void> _startRecording() async {
    try {
      final hasPermissions = await _requestPermissions();
      if (!hasPermissions) return;

      final audioPath = await _getAudioPath();
      debugPrint('Iniciando grabación en: $audioPath');

      await _recorder.startRecorder(
        toFile: audioPath,
        codec: Codec.aacADTS,
      );

      setState(() {
        _audioState = AudioState.recording;
        _recordingDuration = Duration.zero;
        _currentAudioPath = audioPath;
        _isPaused = false;
      });

      _pulseController.repeat();
      _waveController.repeat();

      _recordingTimer =
          Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted && !_isPaused) {
          setState(() {
            _recordingDuration = Duration(seconds: timer.tick);
          });
        }
      });

      debugPrint('Grabación iniciada exitosamente');
    } catch (e) {
      debugPrint('Error al iniciar grabación: $e');
      _showErrorDialog('Error al iniciar la grabación: $e');
    }
  }

  Future<void> _pauseRecording() async {
    try {
      await _recorder.pauseRecorder();
      setState(() {
        _audioState = AudioState.paused;
        _isPaused = true;
      });
      _recordingTimer?.cancel();
      _pulseController.stop();
      _waveController.stop();
      debugPrint('Grabación pausada');
    } catch (e) {
      debugPrint('Error al pausar grabación: $e');
    }
  }

  Future<void> _resumeRecording() async {
    try {
      await _recorder.resumeRecorder();
      setState(() {
        _audioState = AudioState.recording;
        _isPaused = false;
      });
      _pulseController.repeat();
      _waveController.repeat();

      final currentSeconds = _recordingDuration.inSeconds;
      _recordingTimer =
          Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted && !_isPaused) {
          setState(() {
            _recordingDuration =
                Duration(seconds: currentSeconds + timer.tick);
          });
        }
      });
      debugPrint('Grabación reanudada');
    } catch (e) {
      debugPrint('Error al reanudar grabación: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _recorder.stopRecorder();
      _recordingTimer?.cancel();

      if (path != null) {
        setState(() {
          _audioState = AudioState.recorded;
          _totalDuration = _recordingDuration;
          _currentAudioPath = path;
          _isPaused = false;
        });

        _pulseController.stop();
        _waveController.stop();

        widget.onAudioRecorded(_currentAudioPath);
        debugPrint('Grabación completada: $path');
      }
    } catch (e) {
      debugPrint('Error al detener grabación: $e');
      _showErrorDialog('Error al detener la grabación');
    }
  }

  Future<void> _playAudio() async {
    if (_currentAudioPath == null) return;

    try {
      setState(() {
        _audioState = AudioState.playing;
        _playbackDuration = Duration.zero;
      });

      _waveController.repeat();

      await _player.startPlayer(
        fromURI: _currentAudioPath,
        codec: Codec.aacADTS,
        whenFinished: () {
          _onPlaybackComplete();
        },
      );

      debugPrint('Reproducción iniciada');
    } catch (e) {
      debugPrint('Error al reproducir audio: $e');
      setState(() {
        _audioState = AudioState.recorded;
      });
      _waveController.stop();
      _showErrorDialog('Error al reproducir audio: $e');
    }
  }

  void _onPlaybackComplete() {
    if (mounted) {
      setState(() {
        _audioState = AudioState.recorded;
        _playbackDuration = Duration.zero;
      });
      _waveController.stop();
      _playbackTimer?.cancel();
      debugPrint('Reproducción completada');
    }
  }

  Future<void> _stopPlaying() async {
    try {
      await _player.stopPlayer();
      _playbackTimer?.cancel();

      setState(() {
        _audioState = AudioState.recorded;
        _playbackDuration = Duration.zero;
      });

      _waveController.stop();
      debugPrint('Reproducción detenida');
    } catch (e) {
      debugPrint('Error al detener reproducción: $e');
    }
  }

  void _deleteAudio() {
    try {
      if (_currentAudioPath != null) {
        final file = File(_currentAudioPath!);
        if (file.existsSync()) {
          file.deleteSync();
          debugPrint('Archivo eliminado: $_currentAudioPath');
        }
      }

      setState(() {
        _audioState = AudioState.idle;
        _recordingDuration = Duration.zero;
        _playbackDuration = Duration.zero;
        _totalDuration = Duration.zero;
        _currentAudioPath = null;
        _isPaused = false;
      });

      widget.onAudioRecorded(null);
      debugPrint('Audio eliminado');
    } catch (e) {
      debugPrint('Error al eliminar audio: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            ResponsiveHelper.getBorderRadius(context, base: 12),
          ),
        ),
        title: Text(
          'Error',
          style: TextStyle(
            fontSize: ResponsiveHelper.getFontSize(context, 18),
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          message,
          style: TextStyle(
            fontSize: ResponsiveHelper.getFontSize(context, 14),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: TextStyle(
                fontSize: ResponsiveHelper.getFontSize(context, 14),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- UI (sin cambios) ---
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Audio de evidencia',
          style: TextStyle(
            fontSize: ResponsiveHelper.getFontSize(context, 18),
            fontWeight: FontWeight.w500,
            color: const Color(0xFF333333),
          ),
        ),
        SizedBox(height: ResponsiveHelper.getSpacing(context, base: 12)),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(
            ResponsiveHelper.getSpacing(context, base: 20),
          ),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(
              ResponsiveHelper.getBorderRadius(context, base: 12),
            ),
            border: Border.all(
              color: _audioState != AudioState.idle
                  ? const Color(0xFF099AD7)
                  : const Color(0xFFAFB5B3),
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
        return SizedBox(
          height: ResponsiveHelper.responsiveValue(
            context,
            mobile: 60.0,
            tablet: 70.0,
            desktop: 80.0,
          ),
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
                                _audioState == AudioState.playing
                            ? animation.value
                            : 0.3),
                    margin: EdgeInsets.symmetric(
                      horizontal:
                          ResponsiveHelper.getSpacing(context, base: 2),
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
        return const Color(0xFFCD2036);
      case AudioState.playing:
        return const Color(0xFF099AD7);
      case AudioState.recorded:
        return const Color(0xFF56A049);
      default:
        return const Color(0xFFAFB5B3);
    }
  }

  Widget _buildAudioControls() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: ResponsiveHelper.getSpacing(context, base: 8),
      runSpacing: ResponsiveHelper.getSpacing(context, base: 8),
      children: [
        _buildControlButton(),
        if (_audioState == AudioState.recording) _buildPauseButton(),
        if (_audioState == AudioState.paused) _buildResumeButton(),
        if (_audioState == AudioState.recorded) _buildPlayButton(),
        if (_audioState == AudioState.playing) _buildStopPlayButton(),
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
        color = const Color(0xFF099AD7);
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
        onPressed = _resumeRecording;
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
                        color: color.withOpacity(0.5),
                        blurRadius:
                            ResponsiveHelper.getSpacing(context, base: 10),
                        spreadRadius:
                            ResponsiveHelper.getSpacing(context, base: 2),
                      ),
                    ]
                  : null,
            ),
            child: SizedBox(
              width: ResponsiveHelper.responsiveValue(
                context,
                mobile: 60.0,
                tablet: 70.0,
                desktop: 80.0,
              ),
              height: ResponsiveHelper.responsiveValue(
                context,
                mobile: 60.0,
                tablet: 70.0,
                desktop: 80.0,
              ),
              child: ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  shape: const CircleBorder(),
                  padding: EdgeInsets.zero,
                  elevation: 4,
                ),
                child: Icon(
                  icon,
                  size: ResponsiveHelper.getIconSize(context, base: 24),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPauseButton() => _buildSecondaryButton(
        icon: Icons.pause,
        color: const Color(0xFFBC966F),
        onPressed: _pauseRecording,
      );

  Widget _buildResumeButton() => _buildSecondaryButton(
        icon: Icons.fiber_manual_record,
        color: const Color(0xFF56A049),
        onPressed: _resumeRecording,
      );

  Widget _buildPlayButton() => _buildSecondaryButton(
        icon: Icons.play_arrow,
        color: Colors.green,
        onPressed: _playAudio,
      );

  Widget _buildStopPlayButton() => _buildSecondaryButton(
        icon: Icons.stop,
        color: const Color(0xFFCD2036),
        onPressed: _stopPlaying,
      );

  Widget _buildDeleteButton() => _buildSecondaryButton(
        icon: Icons.delete,
        color: const Color(0xFFCD2036),
        onPressed: _deleteAudio,
      );

  Widget _buildSecondaryButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: ResponsiveHelper.responsiveValue(
        context,
        mobile: 48.0,
        tablet: 56.0,
        desktop: 64.0,
      ),
      height: ResponsiveHelper.responsiveValue(
        context,
        mobile: 48.0,
        tablet: 56.0,
        desktop: 64.0,
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: const CircleBorder(),
          padding: EdgeInsets.zero,
          elevation: 2,
        ),
        child: Icon(
          icon,
          size: ResponsiveHelper.getIconSize(context, base: 20),
        ),
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
        durationText =
            '${_formatDuration(_playbackDuration)} / ${_formatDuration(_totalDuration)}';
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
            fontSize: ResponsiveHelper.getFontSize(context, 14),
            fontWeight: FontWeight.w500,
            color: _getVisualizerColor(),
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
