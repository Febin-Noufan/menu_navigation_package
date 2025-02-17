import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MenuSection {
  final String title;
  final List<MenuItem> items;

  MenuSection({required this.title, required this.items});
}

class MenuItem {
  final String shortcut;
  final String label;
  final List<MenuSection>? subMenu;
  final VoidCallback? onTap;
  final Widget Function()? navigateTo;

  MenuItem({
    required this.shortcut,
    required this.label,
    this.subMenu,
    this.onTap,
    this.navigateTo,
  });
}

class CustomButton extends StatelessWidget {
  final String shortcut;
  final String label;
  final bool isSelected;
  final VoidCallback onPressed;

  const CustomButton({
    super.key,
    required this.shortcut,
    required this.label,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        side: BorderSide(
          // width: 1,
          color: isSelected
              ? const Color.fromARGB(255, 79, 78, 78)
              : const Color.fromARGB(255, 70, 69, 69),
        ),
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(12), // Adjust this value as needed
        ),
        backgroundColor: isSelected
            ? const Color(0xFF9E9E9E).withOpacity(0.1)
            : const Color(0xFFE0E0E0),
      ),
      onPressed: onPressed,
      child: SizedBox(
        height: 40,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color.fromARGB(255, 243, 9, 9)
                    : const Color.fromARGB(255, 236, 5, 5),
                borderRadius: BorderRadius.circular(4),
              ),
              alignment: Alignment.center,
              child: Text(
                shortcut,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFF616161) : Colors.black,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DynamicMenu extends StatefulWidget {
  final List<MenuSection> menuData;
  final Function(MenuItem) onMenuItemSelected;
  final String title;

  const DynamicMenu({
    super.key,
    required this.menuData,
    required this.onMenuItemSelected,
    required this.title,
  });

  @override
  State<DynamicMenu> createState() => _DynamicMenuState();
}

class _DynamicMenuState extends State<DynamicMenu> {
  final FocusNode _focusNode = FocusNode();
  final List<List<MenuSection>> _menuStack = [];
  late List<MenuSection> _currentMenu;
  int _selectedSectionIndex = 0;
  int _selectedItemIndex = -1;

  Timer? _escKeyTimer;
  bool _isFirstEscPress = false;

  @override
  void initState() {
    super.initState();
    _currentMenu = widget.menuData;
  }

  void _navigateToSubMenu(MenuItem menuItem) {
    if (menuItem.navigateTo != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EscListenerPage(
            allowRootNavigation: true,
            child: menuItem.navigateTo!(),
          ),
        ),
      );
    } else if (menuItem.subMenu != null && menuItem.subMenu!.isNotEmpty) {
      setState(() {
        _menuStack.add(_currentMenu);
        _currentMenu = menuItem.subMenu!;
        _selectedSectionIndex = 0;
        _selectedItemIndex = -1;
      });
    } else {
      widget.onMenuItemSelected(menuItem);
      if (menuItem.onTap != null) {
        menuItem.onTap!();
      }
    }
  }

  void _navigateBack() {
    if (_menuStack.isNotEmpty) {
      setState(() {
        _currentMenu = _menuStack.removeLast();
        _selectedSectionIndex = 0;
        _selectedItemIndex = -1;
      });
    }
  }

  // ignore: deprecated_member_use
  void _handleKeyEvent(RawKeyEvent event) {
    // ignore: deprecated_member_use
    if (event is RawKeyDownEvent) {
      final key = event.logicalKey.keyLabel.toUpperCase();

      if (key == 'ARROW_UP') {
        setState(() {
          _selectedItemIndex = (_selectedItemIndex - 1)
              .clamp(-1, _currentMenu[_selectedSectionIndex].items.length - 1);
        });
      } else if (key == 'ARROW_DOWN') {
        setState(() {
          _selectedItemIndex = (_selectedItemIndex + 1) %
              _currentMenu[_selectedSectionIndex].items.length;
        });
      } else if (key == 'ENTER' && _selectedItemIndex != -1) {
        _navigateToSubMenu(
            _currentMenu[_selectedSectionIndex].items[_selectedItemIndex]);
      } else if (key == 'ESCAPE') {
        if (_menuStack.isNotEmpty) {
          _navigateBack();
        }
        // _handleEscKey();
      } else if (key == 'BACKSPACE') {
        if (_menuStack.isNotEmpty) {
          _navigateBack();
        }
      } else {
        for (var section in _currentMenu) {
          for (var item in section.items) {
            if (item.shortcut.toUpperCase() == key) {
              _navigateToSubMenu(item);
              return;
            }
          }
        }
      }
    }
  }

  void _handleEscKey() {
    if (_isFirstEscPress) {
      setState(() {
        _currentMenu = widget.menuData;
        _menuStack.clear();
        _selectedSectionIndex = 0;
        _selectedItemIndex = -1;
      });
      _isFirstEscPress = false;
      _escKeyTimer?.cancel();
    } else {
      _isFirstEscPress = true;
      _escKeyTimer = Timer(const Duration(milliseconds: 300), () {
        _isFirstEscPress = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKey: _handleKeyEvent,
      child: Container(
        color: const Color(0xFFE0E0E0), // Light grey background
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 50,
              color: const Color(0xFFBDBDBD), // Grey header
              alignment: Alignment.center,
              child: Text(
                widget.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.black,
                ),
              ),
            ),
            if (_menuStack.isNotEmpty)
              TextButton.icon(
                onPressed: _navigateBack,
                icon: const Icon(Icons.arrow_back, color: Color(0xFF616161)),
                label: const Text(
                  'Back',
                  style: TextStyle(color: Color(0xFF616161)),
                ),
              ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _currentMenu.map((section) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8.0,
                            horizontal: 16.0,
                          ),
                          child: Text(
                            section.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.black, // Black text
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children:
                                section.items.asMap().entries.map((entry) {
                              final itemIndex = entry.key;
                              final item = entry.value;
                              return CustomButton(
                                shortcut: item.shortcut,
                                label: item.label,
                                isSelected: _selectedSectionIndex ==
                                        _currentMenu.indexOf(section) &&
                                    itemIndex == _selectedItemIndex,
                                onPressed: () => _navigateToSubMenu(item),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _escKeyTimer?.cancel();
    _focusNode.dispose();
    super.dispose();
  }
}

class EscListenerPage extends StatefulWidget {
  final Widget child;
  final bool allowRootNavigation;
  final VoidCallback? onEscapeRoot;

  const EscListenerPage({
    super.key,
    required this.child,
    this.allowRootNavigation = false,
    this.onEscapeRoot,
  });

  @override
  State<EscListenerPage> createState() => _EscListenerPageState();
}

class _EscListenerPageState extends State<EscListenerPage> {
  Timer? _escKeyTimer;
  bool _isFirstEscPress = false;

  void _handleKeyEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      final key = event.logicalKey.keyLabel.toUpperCase();

      if (key == 'ESCAPE') {
        if (_isFirstEscPress) {
          if (Navigator.of(context).canPop()) {
            Navigator.pop(context);
          } else if (widget.allowRootNavigation) {
            if (widget.onEscapeRoot != null) {
              widget.onEscapeRoot!();
            } else {
              Navigator.of(context, rootNavigator: true).pop();
            }
          }
          _isFirstEscPress = false;
          _escKeyTimer?.cancel();
        } else {
          _isFirstEscPress = true;
          _escKeyTimer = Timer(const Duration(milliseconds: 300), () {
            _isFirstEscPress = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKey: _handleKeyEvent,
      child: widget.child,
    );
  }

  @override
  void dispose() {
    _escKeyTimer?.cancel();
    super.dispose();
  }
}
