import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
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
  
  // Flutter Sound
  FlutterSoundRecorder? _recorder;
  FlutterSoundPlayer? _player;
  
  // Timer para el contador
  Timer? _recordingTimer;
  Timer? _playbackTimer;
  
  String? _currentAudioPath;

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
    _recorder = FlutterSoundRecorder();
    _player = FlutterSoundPlayer();
    
    await _recorder!.openRecorder();
    await _player!.openPlayer();
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _playbackTimer?.cancel();
    _pulseController.dispose();
    _waveController.dispose();
    _recorder?.closeRecorder();
    _player?.closePlayer();
    super.dispose();
  }

  Future<bool> _checkPermissions() async {
    final microphoneStatus = await Permission.microphone.request();
    final storageStatus = await Permission.storage.request();
    
    return microphoneStatus.isGranted && 
           (storageStatus.isGranted || storageStatus.isPermanentlyDenied); // En Android 13+ storage no es necesario
  }

  Future<String> _getAudioPath() async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'audio_${DateTime.now().millisecondsSinceEpoch}.aac';
    return '${directory.path}/$fileName';
  }

  Future<void> _startRecording() async {
    if (!await _checkPermissions()) {
      _showPermissionDialog();
      return;
    }

    try {
      final audioPath = await _getAudioPath();
      
      await _recorder!.startRecorder(
        toFile: audioPath,
        codec: Codec.aacADTS,
      );

      setState(() {
        _audioState = AudioState.recording;
        _recordingDuration = Duration.zero;
        _currentAudioPath = audioPath;
      });

      _pulseController.repeat();
      _waveController.repeat();
      
      // Iniciar el timer para el contador
      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted) {
          setState(() {
            _recordingDuration = Duration(seconds: timer.tick);
          });
        }
      });

    } catch (e) {
      debugPrint('Error al iniciar grabación: $e');
      _showErrorDialog('Error al iniciar la grabación');
    }
  }

  Future<void> _pauseRecording() async {
    try {
      await _recorder!.pauseRecorder();
      
      setState(() {
        _audioState = AudioState.paused;
      });
      
      _recordingTimer?.cancel();
      _pulseController.stop();
      _waveController.stop();
      
    } catch (e) {
      debugPrint('Error al pausar grabación: $e');
    }
  }

  Future<void> _resumeRecording() async {
    try {
      await _recorder!.resumeRecorder();
      
      setState(() {
        _audioState = AudioState.recording;
      });
      
      _pulseController.repeat();
      _waveController.repeat();
      
      // Reanudar el timer desde donde se quedó
      final currentSeconds = _recordingDuration.inSeconds;
      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted) {
          setState(() {
            _recordingDuration = Duration(seconds: currentSeconds + timer.tick);
          });
        }
      });
      
    } catch (e) {
      debugPrint('Error al reanudar grabación: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      await _recorder!.stopRecorder();
      
      _recordingTimer?.cancel();
      
      setState(() {
        _audioState = AudioState.recorded;
        _totalDuration = _recordingDuration;
      });
      
      _pulseController.stop();
      _waveController.stop();
      
      widget.onAudioRecorded(_currentAudioPath);
      
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

      await _player!.startPlayer(
        fromURI: _currentAudioPath,
        whenFinished: () {
          if (mounted) {
            setState(() {
              _audioState = AudioState.recorded;
              _playbackDuration = Duration.zero;
            });
            _waveController.stop();
            _playbackTimer?.cancel();
          }
        },
      );

      // Timer para actualizar el progreso de reproducción
      _playbackTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
        if (mounted && _audioState == AudioState.playing) {
          setState(() {
            _playbackDuration = Duration(milliseconds: timer.tick * 100);
            // Si llegamos al final, parar
            if (_playbackDuration >= _totalDuration) {
              _playbackDuration = _totalDuration;
            }
          });
        }
      });

    } catch (e) {
      debugPrint('Error al reproducir audio: $e');
      setState(() {
        _audioState = AudioState.recorded;
      });
      _waveController.stop();
    }
  }

  Future<void> _stopPlaying() async {
    try {
      await _player!.stopPlayer();
      _playbackTimer?.cancel();
      
      setState(() {
        _audioState = AudioState.recorded;
        _playbackDuration = Duration.zero;
      });
      
      _waveController.stop();
      
    } catch (e) {
      debugPrint('Error al detener reproducción: $e');
    }
  }

  void _deleteAudio() {
    if (_currentAudioPath != null) {
      final file = File(_currentAudioPath!);
      if (file.existsSync()) {
        file.deleteSync();
      }
    }
    
    setState(() {
      _audioState = AudioState.idle;
      _recordingDuration = Duration.zero;
      _playbackDuration = Duration.zero;
      _totalDuration = Duration.zero;
      _currentAudioPath = null;
    });
    
    widget.onAudioRecorded(null);
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permisos requeridos'),
        content: const Text('Esta aplicación necesita acceso al micrófono para grabar audio.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Configuración'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
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
        return SizedBox(
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
                        color: color,
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

  Widget _buildResumeButton() {
    return ElevatedButton(
      onPressed: _resumeRecording,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        padding: EdgeInsets.all(
          ResponsiveHelper.getSpacing(context, base: 12),
        ),
      ),
      child: Icon(
        Icons.fiber_manual_record,
        size: ResponsiveHelper.getIconSize(context, base: 20),
      ),
    );
  }

  Widget _buildPlayButton() {
    return ElevatedButton(
      onPressed: _playAudio,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        padding: EdgeInsets.all(
          ResponsiveHelper.getSpacing(context, base: 12),
        ),
      ),
      child: Icon(
        Icons.play_arrow,
        size: ResponsiveHelper.getIconSize(context, base: 20),
      ),
    );
  }

  Widget _buildStopPlayButton() {
    return ElevatedButton(
      onPressed: _stopPlaying,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        padding: EdgeInsets.all(
          ResponsiveHelper.getSpacing(context, base: 12),
        ),
      ),
      child: Icon(
        Icons.stop,
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