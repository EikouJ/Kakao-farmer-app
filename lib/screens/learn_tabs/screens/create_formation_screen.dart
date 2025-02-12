import 'package:flutter/material.dart';

class CreateFormationScreen extends StatefulWidget {
  const CreateFormationScreen({super.key});

  @override
  State<CreateFormationScreen> createState() => _CreateFormationScreenState();
}

class _CreateFormationScreenState extends State<CreateFormationScreen> {
  String selectedType = 'Document'; // Type de formation sélectionné
  final TextEditingController linkController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController thumbnailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Créer une nouvelle formation"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Type de formation :",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButton<String>(
              value: selectedType,
              onChanged: (value) {
                setState(() {
                  selectedType = value!;
                });
              },
              items: const [
                DropdownMenuItem(
                  value: 'Document',
                  child: Text('Document'),
                ),
                DropdownMenuItem(
                  value: 'Playlist',
                  child: Text('Playlist'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Affichage des champs en fonction du type sélectionné
            if (selectedType == 'Document') ...[
              const Text(
                "Lien du document :",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: linkController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Entrez le lien du document",
                ),
              ),
            ] else if (selectedType == 'Playlist') ...[
              const Text(
                "Titre de la playlist :",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Entrez le titre de la playlist",
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Prix de la playlist :",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Entrez le prix de la playlist",
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              const Text(
                "Miniature de la playlist (URL) :",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: thumbnailController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Entrez le lien de la miniature",
                ),
              ),
            ],

            const Spacer(),

            // Bouton de création
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 131, 41, 41),
              ),
              onPressed: () {
                if (selectedType == 'Document') {
                  // Action pour créer un document
                  String link = linkController.text;
                  if (link.isNotEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text("Document créé avec le lien : $link")),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Veuillez entrer un lien valide.")),
                    );
                  }
                } else if (selectedType == 'Playlist') {
                  // Action pour créer une playlist
                  String title = titleController.text;
                  String price = priceController.text;
                  String thumbnail = thumbnailController.text;

                  if (title.isNotEmpty &&
                      price.isNotEmpty &&
                      thumbnail.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddVideosScreen(
                          playlistTitle: title,
                          playlistThumbnail: thumbnail,
                          playlistPrice: price,
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Veuillez remplir tous les champs.")),
                    );
                  }
                }
              },
              child: Text(selectedType == 'Document'
                  ? "Créer Document"
                  : "Créer Playlist"),
            ),
          ],
        ),
      ),
    );
  }
}

class AddVideosScreen extends StatefulWidget {
  final String playlistTitle;
  final String playlistThumbnail;
  final String playlistPrice;

  const AddVideosScreen({
    super.key,
    required this.playlistTitle,
    required this.playlistThumbnail,
    required this.playlistPrice,
  });

  @override
  State<AddVideosScreen> createState() => _AddVideosScreenState();
}

class _AddVideosScreenState extends State<AddVideosScreen> {
  final List<Map<String, String>> videos = [];
  final TextEditingController videoTitleController = TextEditingController();
  final TextEditingController videoUrlController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ajouter des vidéos à ${widget.playlistTitle}"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "Ajouter une vidéo :",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: videoTitleController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Titre de la vidéo",
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: videoUrlController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Lien YouTube de la vidéo",
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 131, 41, 41),
              ),
              onPressed: () {
                String videoTitle = videoTitleController.text;
                String videoUrl = videoUrlController.text;

                if (videoTitle.isNotEmpty && videoUrl.isNotEmpty) {
                  setState(() {
                    videos.add({'title': videoTitle, 'url': videoUrl});
                    videoTitleController.clear();
                    videoUrlController.clear();
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Veuillez remplir tous les champs.")),
                  );
                }
              },
              child: const Text("Ajouter Vidéo"),
            ),
            const SizedBox(height: 16),
            const Text(
              "Vidéos ajoutées :",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: videos.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(videos[index]['title']!),
                    subtitle: Text(videos[index]['url']!),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
