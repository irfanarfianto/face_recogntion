import 'dart:io';
import 'package:flutter/material.dart';
import 'package:test_face_recognition/features/attendance/domain/entities/user_entity.dart';
import 'package:test_face_recognition/features/attendance/domain/entities/face_attributes.dart';

class ResultDetailPage extends StatelessWidget {
  final UserEntity user;
  final double similarity;
  final String capturedImagePath;
  final FaceAttributes? faceAttributes;
  final List<double>? capturedEmbedding;

  const ResultDetailPage({
    super.key,
    required this.user,
    required this.similarity,
    required this.capturedImagePath,
    this.faceAttributes,
    this.capturedEmbedding,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Analisis Detil'),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Comparison Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildImageColumn(
                      context,
                      'Terdaftar',
                      user.imageUrl,
                      isNetwork: true,
                    ),
                    Container(
                      height: 60,
                      width: 1,
                      color: Colors.grey.shade300,
                    ),
                    _buildImageColumn(
                      context,
                      'Hasil Scan',
                      capturedImagePath,
                      isNetwork: false,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Identity Section
              const Text(
                'Identitas',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildInfoTile(
                icon: Icons.person,
                label: 'Nama',
                value: user.name,
              ),
              _buildInfoTile(
                icon: Icons.fingerprint,
                label: 'Similarity Score',
                value: similarity.toStringAsFixed(6),
                valueColor: similarity < 1.0
                    ? Colors.green
                    : Colors.red, // Assuming < 1.0 is good match
              ),

              const SizedBox(height: 32),

              // Attributes Section
              if (faceAttributes != null) ...[
                const Text(
                  'Atribut Wajah (Live)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 2.5,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  children: [
                    _buildAttributeCard(
                      'Yaw (Geleng)',
                      faceAttributes!.yaw?.toStringAsFixed(1) ?? "N/A",
                    ),
                    _buildAttributeCard(
                      'Roll (Miring)',
                      faceAttributes!.roll?.toStringAsFixed(1) ?? "N/A",
                    ),
                    _buildAttributeCard(
                      'Pitch (Angguk)',
                      faceAttributes!.pitch?.toStringAsFixed(1) ?? "N/A",
                    ),
                    if (faceAttributes!.smilingProbability != null)
                      _buildAttributeCard(
                        'Senyum',
                        '${(faceAttributes!.smilingProbability! * 100).toStringAsFixed(0)}%',
                      ),
                  ],
                ),
              ],

              const SizedBox(height: 32),

              // Technical Data (Embedding)
              ExpansionTile(
                title: const Text(
                  'Data Vektor (Embedding)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      capturedEmbedding != null
                          ? capturedEmbedding.toString()
                          : "No embedding data",
                      style: const TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 12,
                        fontFamily: 'Courier',
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageColumn(
    BuildContext context,
    String label,
    String? imagePath, {
    required bool isNetwork,
  }) {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey[200],
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            image: DecorationImage(
              image: (imagePath != null && imagePath.isNotEmpty)
                  ? (isNetwork
                        ? NetworkImage(imagePath)
                        : FileImage(File(imagePath)) as ImageProvider)
                  : const AssetImage('assets/placeholder_user.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueAccent, size: 20),
          const SizedBox(width: 16),
          Text(label, style: const TextStyle(color: Colors.grey)),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: valueColor ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttributeCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.blue[50], // Very light blue
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: Colors.blue[800])),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue[900],
            ),
          ),
        ],
      ),
    );
  }
}
