/****************************************
	RagdollController.js
	Disable and enable rigidbodies and colliders on the ragdoll
	
	Copyright Unluck Software	
 	www.chemicalbliss.com											
*****************************************/

using UnityEngine;
using System;
using System.Collections;


public class ToonCharacterController:MonoBehaviour{
    Component[] boneRig;		// Contains the ragdoll bones
    float mass = .1f;	// Mass of each bone
    public Transform projector;		// Shadow projector
    public Transform root;				// Assign the root bone to position the shadow projector
    public Color _bloodColor;
    public GameObject _model;
    public Mesh _bodyMesh;
    
    public ParticleSystem _explodeHeadPS;
    public GameObject _head;
    public Transform _headBone;
    
    public GameObject[] _disableWhenDecapitated;
    public ParticleSystem _bodyPS;
    
    bool _decapitated;
    
    //Blinking
    Color colorOriginal;
    Color color;
    float _R = 2500.0f;
    float _G = 2500.0f;
    float _B = 2500.0f;
    
    bool _randomColor;
    int _blinkCounter;
    int _stopBlink;
    
    public void LateUpdate() {
    	if(!GetComponent<Collider>().enabled && (projector != null) && (root != null)){
    		var tmp_cs1 = projector.transform.position;
            tmp_cs1.x = root.position.x;
            tmp_cs1.z = root.position.z;
            projector.transform.position = tmp_cs1;
    	}
    }
    
    public void Start() {
    	if(root == null)
     	root = transform.Find("Root");
     	if(projector == null)
     	projector = transform.Find("Blob Shadow Projector");
     	if(_model == null)
     	_model = transform.Find("MicroMale").gameObject;
     	if(_headBone == null)
     	_headBone = transform.Find("Head");
    	boneRig = gameObject.GetComponentsInChildren<Rigidbody>(); 
    	disableRagdoll();
    	//Blinking
    	colorOriginal = _model.GetComponent<Renderer>().material.color;
    }
    
    public void Blink(int times,float speed,float red,float green,float blue){
    	CancelInvoke();
    	_randomColor= false;
    	_R = red;
    	_G = green;
    	_B = blue;
    	_stopBlink = times;
    	InvokeRepeating("BlinkInvoke", speed, speed);
    }
    
    public void Blink(int times,float speed){
    	CancelInvoke();
    	_randomColor = true;
    	_stopBlink = times;
    	InvokeRepeating("BlinkInvoke", speed, speed);
    }
    
    public void BlinkInvoke() {
    	if(_blinkCounter < _stopBlink){
    		if(_randomColor){
    			color = new Color((float)UnityEngine.Random.Range(1, 5) ,(float)UnityEngine.Random.Range(1, 5),(float)UnityEngine.Random.Range(1, 5),1.0f);
    		}else{
    			color = new Color(_R , _G , _B ,1.0f);
    		}
    		
    		if(_model.GetComponent<Renderer>().material.color == colorOriginal){
    			_model.GetComponent<Renderer>().material.color = color;
    		}else{
    			_model.GetComponent<Renderer>().material.color = colorOriginal;
    		}
    		_blinkCounter++;
    	}else{
    		_model.GetComponent<Renderer>().material.color = colorOriginal;
    		_blinkCounter = 0;
    		CancelInvoke();
    	}
    }
    
    public void disableRagdoll() {
    	foreach(Component ragdoll in boneRig) {
    		if((ragdoll.GetComponent<Collider>() != null) && ragdoll.GetComponent<Collider>()!=this.GetComponent<Collider>()){
    		ragdoll.GetComponent<Collider>().enabled = false;
    		ragdoll.GetComponent<Rigidbody>().isKinematic = true;
    		ragdoll.GetComponent<Rigidbody>().mass = 0.01f;
    		}
    	}
    	GetComponent<Collider>().enabled = true;
    }
     
    public IEnumerator enableRagdoll(float delay,Vector3 force) {
    	yield return new WaitForSeconds(delay);
    	foreach(Component ragdoll in boneRig) {
    		if(ragdoll.GetComponent<Collider>() != null)
    		ragdoll.GetComponent<Collider>().enabled = true;
    		ragdoll.GetComponent<Rigidbody>().isKinematic = false; 
    		ragdoll.GetComponent<Rigidbody>().mass = mass;
    		if(force.magnitude > 0)
    		ragdoll.GetComponent<Rigidbody>().AddForce(force*UnityEngine.Random.value);
    	}
    	GetComponent<Animator>().enabled=false;
    	GetComponent<Collider>().enabled = false;
    	Destroy(GetComponent<BotControlScript>());
    	GetComponent<Rigidbody>().isKinematic = true;
    	GetComponent<Rigidbody>().useGravity = false;
    	for(int i = 0; i < this._disableWhenDecapitated.Length; i++){
    				_disableWhenDecapitated[i].SetActive(false);
    			}
    }
    
    public void Decapitate(bool explode,float delay,Vector3 force) {
    	if(!_decapitated){
    		_decapitated = true;
    			_model.GetComponent<SkinnedMeshRenderer>().sharedMesh = this._bodyMesh;
    		if(_head != null){
    			if(!explode){
    				GameObject h = (GameObject)Instantiate(_head, _headBone.position, transform.rotation);
    				h.transform.localScale = _headBone.localScale*transform.localScale.x;
    				Physics.IgnoreCollision(gameObject.GetComponent<Collider>(), h.GetComponent<Collider>());
    				Destroy(_headBone.GetComponent<Collider>());
    				h.GetComponent<Renderer>().sharedMaterial = _model.GetComponent<SkinnedMeshRenderer>().sharedMaterial;
    				if(force.magnitude > 0)
    				h.GetComponent<Rigidbody>().AddForce(force*UnityEngine.Random.value);
    				h.GetComponent<Rigidbody>().AddTorque(new Vector3((float)UnityEngine.Random.Range(-10, 10),(float)UnityEngine.Random.Range(-10, 10),(float)UnityEngine.Random.Range(-10, 10)));
					ParticleSystem.MainModule main =  h.transform.Find("Head PS").GetComponent<ParticleSystem>().main; 
						main.startColor = _bloodColor;
    				StartCoroutine(EnableCollisions(gameObject.GetComponent<Collider>(), h.GetComponent<Collider>()));
    			}else{
    				GameObject e = (GameObject)Instantiate(_explodeHeadPS.gameObject, _headBone.position, transform.rotation);
					ParticleSystem.MainModule main =  e.GetComponent<ParticleSystem>().main;
					main.startColor = _bloodColor;
    				Destroy(e, 2.0f);
    			}
    			if(_bodyPS != null){
					ParticleSystem.MainModule main = _bodyPS.main;
					main.startColor = this._bloodColor;
    			_bodyPS.Play();
    			}
    					
    		}
    		StartCoroutine(enableRagdoll(delay, force));
    	}
    }
    
    public IEnumerator EnableCollisions(Collider c1,Collider c2){
    	yield return new WaitForSeconds(1.0f);
    	if((c2 != null) && c1.enabled)
    		Physics.IgnoreCollision(c1,c2, false);
    }
}