// AWS configuration
var awsRegion = 'us-east-1';
var requestId;

var source_language = 'en'
var target_language = 'es'

function babel_select(mode,language) {
  document.getElementById(mode + "_" + language).src = "https://s3.amazonaws.com/tomash-us-east-1/voice-translator/graphics/flags/" + language + "2.png";

  if (mode == 'source') {
    source_language = language;
  } else {
    target_language = language;
  }

}

function babel_unselect_source() {
  document.getElementById("source_en").src = "https://s3.amazonaws.com/tomash-us-east-1/voice-translator/graphics/flags/en.png";
  //document.getElementById("source_gb").src = "https://s3.amazonaws.com/tomash-us-east-1/voice-translator/graphics/flags/gb.png";
  document.getElementById("source_es").src = "https://s3.amazonaws.com/tomash-us-east-1/voice-translator/graphics/flags/es.png";
  //document.getElementById("source_ca").src = "https://s3.amazonaws.com/tomash-us-east-1/voice-translator/graphics/flags/ca.png";
  //document.getElementById("source_fr").src = "https://s3.amazonaws.com/tomash-us-east-1/voice-translator/graphics/flags/fr.png";
}

function babel_unselect_target() {
  document.getElementById("target_en").src = "https://s3.amazonaws.com/tomash-us-east-1/voice-translator/graphics/flags/en.png";
  document.getElementById("target_gb").src = "https://s3.amazonaws.com/tomash-us-east-1/voice-translator/graphics/flags/gb.png";
  document.getElementById("target_de").src = "https://s3.amazonaws.com/tomash-us-east-1/voice-translator/graphics/flags/de.png";
  document.getElementById("target_pl").src = "https://s3.amazonaws.com/tomash-us-east-1/voice-translator/graphics/flags/pl.png";
  document.getElementById("target_es").src = "https://s3.amazonaws.com/tomash-us-east-1/voice-translator/graphics/flags/es.png";
  document.getElementById("target_ca").src = "https://s3.amazonaws.com/tomash-us-east-1/voice-translator/graphics/flags/ca.png";
  document.getElementById("target_fr").src = "https://s3.amazonaws.com/tomash-us-east-1/voice-translator/graphics/flags/fr.png";
  document.getElementById("target_ja").src = "https://s3.amazonaws.com/tomash-us-east-1/voice-translator/graphics/flags/ja.png";
  document.getElementById("target_ru").src = "https://s3.amazonaws.com/tomash-us-east-1/voice-translator/graphics/flags/ru.png";
  document.getElementById("target_it").src = "https://s3.amazonaws.com/tomash-us-east-1/voice-translator/graphics/flags/it.png";
  document.getElementById("target_sv").src = "https://s3.amazonaws.com/tomash-us-east-1/voice-translator/graphics/flags/sv.png";
}

function babel_stop() {
  document.getElementById("stop_button").src = "https://s3.amazonaws.com/tomash-us-east-1/voice-translator/graphics/stop2.png";
  document.getElementById("start_button").src = "https://s3.amazonaws.com/tomash-us-east-1/voice-translator/graphics/start.png";

  document.getElementById("stop_button").classList.remove('clickableimage');
  document.getElementById("start_button").classList.add('clickableimage');
}

function babel_start() {
  document.getElementById("stop_button").src = "https://s3.amazonaws.com/tomash-us-east-1/voice-translator/graphics/stop.png";
  document.getElementById("start_button").src = "https://s3.amazonaws.com/tomash-us-east-1/voice-translator/graphics/start2.png";

  document.getElementById("stop_button").classList.add('clickableimage');
  document.getElementById("start_button").classList.remove('clickableimage');
}





AWS.config.update({
  region: awsRegion,
  credentials: new AWS.CognitoIdentityCredentials({
    IdentityPoolId: IdentityPoolId
  })
});

// S3 object for storing input and output audio
var s3 = new AWS.S3({
  apiVersion: '2006-03-01',
  params: {Bucket: bucketName},
  region: awsRegion
});

// Define variables for audio recorder
var recorder;
var recorderInput;
var getUserMediaStream;
var AudioContext = window.AudioContext || window.webkitAudioContext;
var audioContext;

// Get buttons from DOM
var recordStartButton = document.getElementById('start_button');
var recordStopButton = document.getElementById('stop_button');

// Add click event callbacks to buttons
recordStartButton.addEventListener('click', startRecording);
recordStopButton.addEventListener('click', stopRecording);

// Generate unique identifiers
function guid() {
  function s4() {
    return Math.floor((1 + Math.random()) * 0x10000)
      .toString(16)
      .substring(1);
  }
  return s4() + s4() + '-' + s4() + '-' + s4() + '-' + s4() + '-' + s4() + s4() + s4();
}

// Check if URL returns HTTP 200 OK
function urlExists(url) {
  var http = new XMLHttpRequest();
  http.open('HEAD', url, false);
  http.send();
  return http.status==200;
}

// Polling for result
function poll(fn, timeout, interval) {
    var endTime = Number(new Date()) + (timeout || 2000);
    interval = interval || 100;

    var checkCondition = function(resolve, reject) {
        // If the condition is met, we're done!
        var result = fn();
        if(result) {
            resolve(result);
        }
        // If the condition isn't met but the timeout hasn't elapsed, go again
        else if (Number(new Date()) < endTime) {
            setTimeout(checkCondition, interval, resolve, reject);
        }
        // Didn't match and too much time, reject!
        else {
            reject(new Error('timed out for ' + fn + ': ' + arguments));
        }
    };

    return new Promise(checkCondition);
}

// Adjust buttons and message for processing
function processingView() {
  // Show processing message
  document.getElementById('processing').style.display = 'inline';
  // Disable all buttons
  recordStartButton.disabled = true;
  recordStopButton.disabled = true;
}

// Adjust buttons and message for recording
function recordingView() {
  // Hide processing message
  document.getElementById('processing').style.display = 'none';
  // Disable all buttons
  recordStartButton.disabled = true;
  recordStopButton.disabled = false;
}

// Reset buttons and hide messages
function resetView() {
  // Hide processing message
  document.getElementById('processing').style.display = 'none';
  // Disable all buttons
  recordStartButton.disabled = false;
  recordStopButton.disabled = true;
}

// Generate request ID
function generateRequestId() {
  return guid();
}

// Record audio with device microphone
function startRecording() {


  audioContext = new AudioContext;

  // Adjust buttons and message for recording
  recordingView();

  // Define constraints object for MediaStream
  var constraints = { audio: true, video: false }

  // Access MediaDevices to get audio stream
  navigator.mediaDevices.getUserMedia(constraints).then(function(stream) {
    getUserMediaStream = stream;
    recorderInput = audioContext.createMediaStreamSource(stream);
    // Create Recorder.js object and start recording
    recorder = new Recorder(recorderInput, { numChannels: 1 })
    recorder.record()
  }).catch(function(err) {
    alert(err);
    // Reset buttons and message in case of failure
    resetView();
    // Inform user that recording failed (most likely was blocked by browser due
    // to insecure origin)
    alert("....Recording failed, try using Firefox or local copy of the app from your machine.");
  });
}

function stopRecording() {

  // Reset buttons and message
  resetView();

  // Stop recording with Recorder.js object
  recorder.stop();

  // Stop microphone and get recorded audio
  getUserMediaStream.getAudioTracks()[0].stop();

  // Pass blob with audio data to callback
  recorder.exportWAV(uploadAudioRecording)

}



function uploadAudioRecording(blob) {

  // Show processing phase in the UI
  processingView();

  // Generate unique ID for upload audio file request
  requestId = generateRequestId();

  // Create key for S3 object and upload input audio file
  var inputKey = 'input/' + requestId + '.wav'

  s3.upload({
    Key: inputKey,
    Body: blob
  }, function(err, data) {
    if (err) {
      return alert('There was an error uploading your recording: ', err.message);
    } else {

      var lambda = new AWS.Lambda({region: awsRegion, apiVersion: '2015-03-31'});
      var input = {
         FunctionName : lambdaFunction,
         InvocationType : 'RequestResponse',
         LogType : 'None',
         Payload: JSON.stringify({"bucket": bucketName, "key": inputKey, "sourceLanguage": source_language, "targetLanguage" : target_language})
      };

      lambda.invoke(input, function(err, data) {
             if (err) {
               console.log(err);
               alert("There was a problem with Lambda function!!! ");
             } else {
               var resultUrl = data.Payload.replace(/['"]+/g, '');
               resetView();
               document.getElementById('audio-output').innerHTML = '<audio controls autoplay><source src="' + resultUrl + '" type="audio/mpeg"></audio><br/>';
             }
          });
    }
  });

}
