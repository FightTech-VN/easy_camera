# Easy Camera
pub.dev: https://pub.dev/packages/easy_camera_plus

+ Custom frame camera view
+ Support record video with camera

# How to use 
```
 if (imagePath != null)
              SizedBox(
                width: 400,
                height: 400 * 1.48,
                child: imagePath?.contains('http') == true
                    ? Image.network(imagePath!)
                    : Image.asset(imagePath!),
              ),
            TextButton.icon(
              onPressed: () {
                Navigator.of(context)
                    .push(
                  MaterialPageRoute(
                    builder: (context) => const CameraScreen(),
                  ),
                )
                    .then((value) {
                  setState(() {
                    imagePath = value;
                  });
                });
              },
              icon: const Icon(Icons.photo_album),
              label: const Text('Take Photo'),
            ),
```

# screenshot
![Alt text](docs/screenshot.png)