import 'package:flutter/material.dart';

class CartScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Кошик')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: TextFormField(
            controller: _controller,
            focusNode: _focusNode,
            decoration: InputDecoration(
              labelText: 'Назва товару',
              hintText: 'Введіть товар',
              prefixIcon: Icon(Icons.shopping_cart),
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Поле не може бути порожнім';
              }
              return null;
            },
          ),
        ),
      ),
    );
  }
}
