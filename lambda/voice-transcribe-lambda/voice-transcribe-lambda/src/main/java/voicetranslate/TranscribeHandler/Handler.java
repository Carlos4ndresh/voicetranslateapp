package voicetranslate.TranscribeHandler;

import java.io.File;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.LambdaLogger;
import com.amazonaws.services.lambda.runtime.RequestHandler;
import com.amazonaws.services.polly.AmazonPolly;
import com.amazonaws.services.polly.AmazonPollyClientBuilder;
import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.AmazonS3ClientBuilder;
import com.amazonaws.services.s3.model.GetObjectRequest;
import com.amazonaws.services.translate.AmazonTranslate;
import com.amazonaws.services.translate.AmazonTranslateClient;
import com.amazonaws.services.translate.model.TranslateTextRequest;
import com.amazonaws.services.translate.model.TranslateTextResult;
import com.amazonaws.transcribestreaming.TranscribeStreamingClientWrapper;
import com.amazonaws.transcribestreaming.TranscribeStreamingSynchronousClient;

import software.amazon.awssdk.services.transcribestreaming.model.LanguageCode;

public class Handler implements RequestHandler<Input, String> {

	AmazonS3 s3 = AmazonS3ClientBuilder.standard().build();
	AmazonTranslate translate = AmazonTranslateClient.builder().build();
	AmazonPolly polly = AmazonPollyClientBuilder.defaultClient();

	@Override
	public String handleRequest(Input name, Context context) {

		LambdaLogger logger = context.getLogger();

		logger.log("Bucket: " + name.getBucket());
		logger.log("Key: " + name.getKey());
		logger.log("Source Language: " + name.getSourceLanguage());
		logger.log("Target: " + name.getTargetLanguage());

		//Converting Audio to Text using Amazon Transcribe service.
		String transcript = transcribe(logger, name.getBucket(), name.getKey(), name.getSourceLanguage());

		//Translating text from one language to another using Amazon Translate service.
		//String translatedText = translate(logger, transcript, name.getSourceLanguage(), name.getTargetLanguage());

		return "You said: " + transcript;
	}

	private String transcribe(LambdaLogger logger, String bucket, String key, String sourceLanguage) {
		
		LanguageCode languageCode = LanguageCode.EN_US;
		
		if ( sourceLanguage.equals("es") ) {
			languageCode = LanguageCode.ES_US;
		}
		
		if ( sourceLanguage.equals("gb") ) {
			languageCode = LanguageCode.EN_GB;
		}
		
		if ( sourceLanguage.equals("ca") ) {
			languageCode = LanguageCode.FR_CA;
		}
		
		if ( sourceLanguage.equals("fr") ) {
			languageCode = LanguageCode.FR_FR;
		}
		
		
		File inputFile = new File("/tmp/input.wav");
		
    	s3.getObject(new GetObjectRequest(bucket, key), inputFile);

        TranscribeStreamingSynchronousClient synchronousClient = new TranscribeStreamingSynchronousClient(TranscribeStreamingClientWrapper.getClient());
        String transcript = synchronousClient.transcribeFile(languageCode, inputFile);
     
        logger.log("Transcript: " + transcript);
 
        return transcript;
	}
	
	private String translate(LambdaLogger logger, String text, String sourceLanguage, String targetLanguage) {
		
		if (targetLanguage.equals("ca")) {
			targetLanguage = "fr";
		}
		
		if (targetLanguage.equals("gb")) {
			targetLanguage = "en";
		}
		
		TranslateTextRequest request = new TranslateTextRequest().withText(text)
                .withSourceLanguageCode(sourceLanguage)
                .withTargetLanguageCode(targetLanguage);
        TranslateTextResult result  = translate.translateText(request);
        
        String translatedText = result.getTranslatedText();
        
        logger.log("Translation: " + translatedText);
        
        return translatedText;
		
	}

}

class Input {
	private String bucket;
	private String key;
	private String sourceLanguage;
	private String targetLanguage;

	public String getBucket() {
		return bucket;
	}

	public void setBucket(String bucket) {
		this.bucket = bucket;
	}

	public String getKey() {
		return key;
	}

	public void setKey(String key) {
		this.key = key;
	}

	public String getSourceLanguage() {
		return sourceLanguage;
	}

	public void setSourceLanguage(String sourceLanguage) {
		this.sourceLanguage = sourceLanguage;
	}

	public String getTargetLanguage() {
		return targetLanguage;
	}

	public void setTargetLanguage(String targetLanguage) {
		this.targetLanguage = targetLanguage;
	}
}

