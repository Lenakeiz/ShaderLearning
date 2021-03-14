using UnityEngine;
public class LightPulse: MonoBehaviour {
	private Light myLight;
	public float maxRange = 1f;
	public float minRange = 0f;
	public float pulseSpeed = 1f; //here, a value of 0.5f would take 2 seconds and a value of 2f would take half a second
	private float targetRange = 1f;
	private float currentRange;    
	
	
	void Start(){
		myLight = GetComponent<Light>();
	}    
	void Update(){
		currentRange = Mathf.MoveTowards(myLight.range,targetRange, Time.deltaTime*pulseSpeed * Random.Range(0, 5));
		if(currentRange >= maxRange){
			currentRange = maxRange;
			targetRange = minRange;
		}else if(currentRange <= minRange){
			currentRange = minRange;
			targetRange = maxRange;
		}
		myLight.range = currentRange;
	}
}