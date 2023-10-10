const video = document.getElementById('video');

Promise.all([
  faceapi.nets.tinyFaceDetector.loadFromUri('/models'),
  faceapi.nets.faceLandmark68Net.loadFromUri('/models'),
  faceapi.nets.faceRecognitionNet.loadFromUri('/models'),
  faceapi.nets.faceExpressionNet.loadFromUri('/models')
]).then(startVideo);

function startVideo() {
  navigator.mediaDevices.getUserMedia({ video: {} })
    .then(stream => {
      video.srcObject = stream;
      video.play();
      video.addEventListener('loadedmetadata', () => {
        // Video yüklendiğinde bu işlemi gerçekleştirin
        const canvas = faceapi.createCanvasFromMedia(video);
        document.body.append(canvas);
        const displaySize = { width: video.width, height: video.height };
        faceapi.matchDimensions(canvas, displaySize);
        setInterval(async () => {
          const detections = await faceapi.detectAllFaces(video, new faceapi.TinyFaceDetectorOptions()).withFaceLandmarks().withFaceExpressions();
          const resizedDetections = faceapi.resizeResults(detections, displaySize);
          canvas.getContext('2d').clearRect(0, 0, canvas.width, canvas.height);
          faceapi.draw.drawDetections(canvas, resizedDetections);
          faceapi.draw.drawFaceLandmarks(canvas, resizedDetections);
          faceapi.draw.drawFaceExpressions(canvas, resizedDetections);
        }, 100);
      });
    })
    .catch(error => {
      console.error('Kamera erişimi hatası: ', error);
    });
}

const startButton = document.getElementById('startButton');

startButton.addEventListener('click', async () => {
  try {
    const stream = await navigator.mediaDevices.getUserMedia({ video: true });
    video.srcObject = stream;
    // Kameraya izin verildiğinde videoyu başlat
    video.play();
  } catch (error) {
    console.error('Kamera erişimi hatası: ', error);
  }
});

let isFullscreen = false;

video.addEventListener('click', function() {
  if (isFullscreen) {
    video.style.width = 'auto';
    video.style.height = 'auto';
  }
  isFullscreen = !isFullscreen;
});

const canvas = faceapi.createCanvasFromMedia(video);
document.body.append(canvas);

function resizeCanvas() {
    canvas.width = video.width;
    canvas.height = video.height;
}

// Sayfa yüklendiğinde ve pencere boyutu değiştiğinde boyutları güncelleyin
window.addEventListener('load', resizeCanvas);
window.addEventListener('resize', resizeCanvas);