// Example: Using maintainPositionOnUpdate feature
// This demonstrates how the feature prevents scroll jumping during AI message streaming

import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

/// Example chat page with AI message streaming
class AIChatPage extends StatelessWidget {
  const AIChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StreamChannelHeader(),
      body: Column(
        children: [
          // Message list with position preservation (enabled by default)
          Expanded(
            child: StreamMessageListView(
              // Position preservation is enabled by default
              // The list won't jump when AI messages grow character by character
              maintainPositionOnUpdate: true,
              
              // All other parameters work normally
              messageBuilder: (context, details, messages, defaultWidget) {
                return defaultWidget;
              },
            ),
          ),
          StreamMessageInput(),
        ],
      ),
    );
  }
}

/// Example: Disabling the feature if needed
class StandardChatPage extends StatelessWidget {
  const StandardChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StreamChannelHeader(),
      body: Column(
        children: [
          Expanded(
            child: StreamMessageListView(
              // Disable if you want default Flutter scroll behavior
              maintainPositionOnUpdate: false,
            ),
          ),
          StreamMessageInput(),
        ],
      ),
    );
  }
}

/// Example: Simulating AI streaming message
/// (This is just to demonstrate the use case - actual AI integration varies)
class AIStreamingExample extends StatefulWidget {
  const AIStreamingExample({super.key});

  @override
  State<AIStreamingExample> createState() => _AIStreamingExampleState();
}

class _AIStreamingExampleState extends State<AIStreamingExample> {
  String _currentMessage = '';
  
  // Simulates AI streaming by adding characters over time
  void _simulateAIStreaming() async {
    const fullResponse = 'This is a simulated AI response that streams '
        'character by character. Without the maintainPositionOnUpdate feature, '
        'the message list would jump on each character addition. With the '
        'feature enabled, the list position remains stable for users who are '
        'reading previous messages.';
    
    _currentMessage = '';
    
    for (var i = 0; i < fullResponse.length; i++) {
      await Future.delayed(const Duration(milliseconds: 50));
      if (mounted) {
        setState(() {
          _currentMessage = fullResponse.substring(0, i + 1);
        });
        
        // Update the message in the channel
        // In real implementation, you'd update the actual message object
        // This causes the message bubble to grow, triggering position preservation
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Streaming Example'),
        actions: [
          IconButton(
            icon: const Icon(Icons.play_arrow),
            onPressed: _simulateAIStreaming,
            tooltip: 'Start AI streaming',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamMessageListView(
              // Feature enabled - list won't jump during streaming
              maintainPositionOnUpdate: true,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Current streamed text: $_currentMessage',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          StreamMessageInput(),
        ],
      ),
    );
  }
}

/// Example: Testing the feature behavior
class FeatureTestPage extends StatefulWidget {
  const FeatureTestPage({super.key});

  @override
  State<FeatureTestPage> createState() => _FeatureTestPageState();
}

class _FeatureTestPageState extends State<FeatureTestPage> {
  bool _maintainPosition = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Position Preservation Test'),
        actions: [
          Switch(
            value: _maintainPosition,
            onChanged: (value) {
              setState(() {
                _maintainPosition = value;
              });
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Center(
              child: Text(_maintainPosition ? 'Enabled' : 'Disabled'),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Info banner
          Container(
            color: Colors.blue.shade100,
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Feature: ${_maintainPosition ? "ENABLED" : "DISABLED"}\n'
              'Scroll away from bottom and watch a message grow.\n'
              'With feature enabled: position stays stable.\n'
              'With feature disabled: position may jump.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          Expanded(
            child: StreamMessageListView(
              key: ValueKey(_maintainPosition), // Force rebuild on toggle
              maintainPositionOnUpdate: _maintainPosition,
            ),
          ),
          StreamMessageInput(),
        ],
      ),
    );
  }
}
