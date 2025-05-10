import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  initializeDateFormatting('zh_CN', null).then((_) {
  runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '智能点名表',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: const AttendanceScreen(),
    );
  }
}

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final List<String> _names = [];
  final Set<String> _checkedNames = {};
  String _currentConfig = '';
  Map<String, List<String>> _configs = {};
  bool _isConfigOpen = false;
  final TextEditingController _nameInputController = TextEditingController();
  final TextEditingController _configNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
    _startTimeUpdater();
  }
  
  String _currentDate = '';
  String _currentTime = '';
  
  void _startTimeUpdater() {
    _updateTime();
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        _startTimeUpdater();
      }
    });
  }
  
  void _updateTime() {
    final now = DateTime.now();
    setState(() {
      try {
        _currentDate = DateFormat.yMMMMEEEEd('zh_CN').format(now);
        _currentTime = DateFormat.Hms('zh_CN').format(now);
      } catch (e) {
        // 如果格式化失败，使用简单格式
        _currentDate = DateFormat('yyyy年MM月dd日').format(now);
        _currentTime = DateFormat('HH:mm:ss').format(now);
      }
    });
  }
  
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final configsJson = prefs.getString('configs');
    if (configsJson != null) {
      final Map<String, dynamic> configsMap = jsonDecode(configsJson);
      _configs = configsMap.map((key, value) => 
        MapEntry(key, List<String>.from(value)));
      
      if (_configs.isNotEmpty) {
        _currentConfig = _configs.keys.first;
        _names.clear();
        _names.addAll(_configs[_currentConfig]!);
        
        // 加载勾选状态
        _checkedNames.clear();
        for (var name in _names) {
          if (prefs.getBool(name) == true) {
            _checkedNames.add(name);
          }
        }
      }
    }
    
    setState(() {});
}

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // 保存配置
    final configsMap = <String, dynamic>{};
    _configs.forEach((key, value) {
      configsMap[key] = value;
    });
    await prefs.setString('configs', jsonEncode(configsMap));
    
    // 保存勾选状态
    for (var name in _names) {
      await prefs.setBool(name, _checkedNames.contains(name));
    }
  }
  
  void _toggleNameCheck(String name) {
    setState(() {
      if (_checkedNames.contains(name)) {
        _checkedNames.remove(name);
      } else {
        _checkedNames.add(name);
      }
      _saveData();
    });
  }
  
  void _selectAll() {
    setState(() {
      _checkedNames.addAll(_names);
      _saveData();
    });
  }
  
  void _deselectAll() {
    setState(() {
      _checkedNames.clear();
      _saveData();
    });
  }
  
  void _toggleConfig() {
    setState(() {
      _isConfigOpen = !_isConfigOpen;
      if (_isConfigOpen) {
        _nameInputController.text = _names.join('\n');
        _configNameController.text = _currentConfig;
      }
    });
  }
  
  void _saveConfig() {
    final configName = _configNameController.text.trim();
    final nameInput = _nameInputController.text.trim();
    
    if (configName.isEmpty || nameInput.isEmpty) {
      _showMessage('配置名称和点名列表不能为空');
      return;
    }
    
    setState(() {
      final nameList = nameInput.split('\n').where((name) => name.trim().isNotEmpty).toList();
      _configs[configName] = nameList;
      _currentConfig = configName;
      _names.clear();
      _names.addAll(nameList);
      _saveData();
      _showMessage('配置已保存');
    });
  }
  
  void _loadConfig(String configName) {
    if (!_configs.containsKey(configName)) return;
    
    setState(() {
      _currentConfig = configName;
      _names.clear();
      _names.addAll(_configs[configName]!);
      _saveData();
    });
  }
  
  void _deleteConfig() {
    final configName = _currentConfig;
    if (_configs.length <= 1) {
      _showMessage('至少保留一个配置');
      return;
    }
    
    setState(() {
      _configs.remove(configName);
      _currentConfig = _configs.keys.first;
      _names.clear();
      _names.addAll(_configs[_currentConfig]!);
      _saveData();
      _showMessage('配置已删除');
    });
  }
  
  void _clearAllData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认清除'),
        content: const Text('确定要清除所有数据吗？此操作无法撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              _configs = {};
              _names.clear();
              _checkedNames.clear();
              _currentConfig = '';
              Navigator.pop(context);
              _showMessage('所有数据已清除');
              setState(() {});
            },
            child: const Text('确认', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
  
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (_isConfigOpen) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('点名配置'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _toggleConfig,
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteConfig,
              tooltip: '删除当前配置',
            ),
            IconButton(
              icon: const Icon(Icons.delete_forever),
              onPressed: _clearAllData,
              tooltip: '清除所有数据',
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 配置选择
              if (_configs.isNotEmpty) ...[
                const Text('选择配置:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: _configs.keys.map((name) => 
                    ChoiceChip(
                      label: Text(name),
                      selected: name == _currentConfig,
                      onSelected: (_) => _loadConfig(name),
                    )
                  ).toList(),
                ),
                const Divider(),
              ],
              
              // 配置名输入
              TextField(
                controller: _configNameController,
                decoration: const InputDecoration(
                  labelText: '配置名称',
                  hintText: '输入配置名称',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              
              // 名单编辑
              const Text('编辑点名列表:', style: TextStyle(fontWeight: FontWeight.bold)),
              const Text('每行一个名字', style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 8),
              Expanded(
                child: TextField(
                  controller: _nameInputController,
                  decoration: const InputDecoration(
                    hintText: '输入名单，每行一个名字',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                ),
              ),
              const SizedBox(height: 16),
              
              // 保存按钮
              ElevatedButton.icon(
                onPressed: _saveConfig,
                icon: const Icon(Icons.save),
                label: const Text('保存配置'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('点名表', style: theme.textTheme.titleLarge),
            if (_currentConfig.isNotEmpty)
              Text(_currentConfig, style: theme.textTheme.bodySmall),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _toggleConfig,
            tooltip: '配置',
          ),
        ],
      ),
      body: Column(
        children: [
          // 日期和时间
          Container(
            color: theme.colorScheme.primaryContainer,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_currentDate, style: theme.textTheme.bodyMedium),
                      Text(_currentTime, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                // 出勤统计
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '出勤: ${_checkedNames.length}/${_names.length}',
                    style: TextStyle(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // 全选/取消按钮
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton.icon(
                  onPressed: _selectAll,
                  icon: const Icon(Icons.check_circle),
                  label: const Text('全选'),
                ),
                OutlinedButton.icon(
                  onPressed: _deselectAll,
                  icon: const Icon(Icons.cancel),
                  label: const Text('取消选择'),
                ),
              ],
            ),
          ),
          
          // 名单列表
          Expanded(
            child: _names.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.person_off, size: 64, color: theme.colorScheme.primary.withOpacity(0.5)),
                        const SizedBox(height: 16),
                        Text('名单为空，请点击右上角设置按钮添加名单',
                             style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.primary)),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _names.length,
                    itemBuilder: (context, index) {
                      final name = _names[index];
                      final isChecked = _checkedNames.contains(name);
                      
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        color: isChecked 
                            ? theme.colorScheme.primaryContainer.withOpacity(0.7)
                            : null,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isChecked
                                ? theme.colorScheme.primary
                                : theme.colorScheme.surfaceVariant,
                            child: isChecked
                                ? Icon(Icons.check, color: theme.colorScheme.onPrimary)
                                : Text(name.substring(0, 1), 
                                      style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
                          ),
                          title: Text(name, style: TextStyle(
                            fontWeight: isChecked ? FontWeight.bold : FontWeight.normal,
                          )),
                          trailing: Checkbox(
                            value: isChecked,
                            onChanged: (_) => _toggleNameCheck(name),
                          ),
                          onTap: () => _toggleNameCheck(name),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
