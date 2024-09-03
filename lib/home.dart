import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController _cepController = TextEditingController();
  String _resultado = 'Seu endereço aqui';

  void _buscarEndereco() async {
    String cep = _cepController.text;
    if (cep.isEmpty || cep.length != 8 || !RegExp(r'^[0-9]+$').hasMatch(cep)) {
      setState(() {
        _resultado = 'CEP inválido';
      });
      return;
    }

    final url = Uri.parse('http://viacep.com.br/ws/$cep/json/');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> dados = json.decode(response.body);
        if (dados.containsKey('erro')) {
          setState(() {
            _resultado = 'CEP não encontrado';
          });
        } else {
          setState(() {
            _resultado = '''
                        Endereço: ${dados['logradouro']}
                        Bairro: ${dados['bairro']}
                        Cidade: ${dados['localidade']}
                        Estado: ${dados['uf']}
                      ''';
          });
        }
      } else {
        setState(() {
          _resultado = 'Erro na requisição';
        });
      }
    } catch (e) {
      setState(() {
        _resultado = 'Erro ao buscar endereço';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Via Cep'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _cepController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Digite o CEP',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _buscarEndereco,
              child: const Text('Buscar'),
            ),
            const SizedBox(height: 16),
            Text(
              _resultado,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
