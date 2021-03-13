/****************************************
	GameObjectSpawner.js v0.0*
	Copyright 2013 Unluck Software	
 	www.chemicalbliss.com			
 	*script has been hardcoded to work with this the toon characters pack														
*****************************************/

using UnityEngine;
using System;
using System.Collections.Generic;


public class GameObjectSpawner_Characters:MonoBehaviour{
    	//Used to sort particle system list
    //Visible properties
    public GameObject[] particles;			//gameObjects to spawn (used to only be particle systems aka var naming)
    public Material[] materials;
    public Color[] cameraColors;
    public int maxButtons = 10;			//Maximum buttons per page	
    public bool spawnOnAwake = true;	//Instantiate the first model on start
    public bool showInfo;				//Show info text on start
    public string removeTextFromButton;	//Unwanted text 
    public string removeTextFromMaterialButton;//Unwanted text 
    public float autoChangeDelay;
   // public GUITexture image;
    //Hidden properties
    int page = 0;			//Current page
    int pages;				//Number of pages
    string currentGOInfo;	//Current particle info
    public GameObject currentGO;	//GameObject currently on stage
    Color currentColor;
    bool isPS;			//Toggle to check if this is a PS or a GO
    
    Material material;		
    bool _active = true;
    
    int counter = -1;
  //  int matCounter = -1;
    int colorCounter;
    
    
    public GUIStyle bigStyle;
    
    
    public void Start(){
    
    	
    	//Sort particle system list alphabeticly
      // particles.Sort(particles, function(g1,g2) String.Compare(g1.name, g2.name));
      //  materials.Sort(materials, function(g1,g2) String.Compare(g1.name, g2.name));
    	//Calculate number of pages
    	pages = (int)Mathf.Ceil((float)((particles.Length -1 )/ maxButtons));
    	//Debug.Log(pages);
    	if(spawnOnAwake){
    		counter=0;
    		ReplaceGO(particles[counter]);
    		Info(particles[counter],  counter);
    		}
    	if(autoChangeDelay > 0){
    		InvokeRepeating("NextModel", autoChangeDelay,autoChangeDelay);
    	
    	}
    	
    }
    
    public void Update() {
    	
    //	if(Input.GetKeyDown(KeyCode.Space)) {
    //    	if(_active){
    //    		_active = false;
    //    		if(image)
    //    		image.enabled = false;
    //    	}else{
    //    		_active = true;
    //    		if(image)
    //    		image.enabled = true;
    //    	}
    //	}
    //	if(Input.GetKeyDown(KeyCode.RightArrow)) {
    //		NextModel ();
    //	}
    //	if(Input.GetKeyDown(KeyCode.LeftArrow)) {
    //		counter--;
    //		if(counter < 0) counter = particles.Length-1;
    //		ReplaceGO(particles[counter]);
    //		
    //		Info(particles[counter],  counter+1);
    //		
    //	}
    //	if(Input.GetKeyDown(KeyCode.UpArrow) && materials.Length>0) {
    //		matCounter++;
    //		if(matCounter > materials.Length -1) matCounter = 0;
    //		material = materials[matCounter];
    //		if(currentGO){
    //			if(currentGO.renderer){
    //			currentGO.renderer.sharedMaterial = material;
    //			}else{
    //				
    //				currentGO.gameObject.Find("MicroMale").renderer.sharedMaterial = material;
    //			
    //			}
    //		}
    //	}
    //	if(Input.GetKeyDown(KeyCode.DownArrow) && materials.Length>0) {
    //		matCounter--;
    //		if(matCounter < 0) matCounter = materials.Length-1;
    //		material = materials[matCounter];
    //		if(currentGO){
    //			if(currentGO.renderer){
    //			currentGO.renderer.sharedMaterial = material;
    //			}else{
    //				
    //				currentGO.gameObject.Find("MicroMale").renderer.sharedMaterial = material;
    //			
    //			}
    //		}
    //		
    //	}
    //	if(Input.GetKeyDown(KeyCode.B)) {
    //		colorCounter++;
    //		if(colorCounter > cameraColors.Length -1) colorCounter = 0;
    //		
    //	}
    //	Camera.main.backgroundColor = Color.Lerp(Camera.main.backgroundColor, cameraColors[colorCounter], Time.deltaTime*3);
    //	
    }
    
    public void NextModel() {
    	
    		counter++;
    		if(counter > particles.Length -1) counter = 0;
    		ReplaceGO(particles[counter]);
    		Info(particles[counter],  counter+1);
    
    }
    
    public void OnGUI() {
    	if(showInfo)GUI.Label (new Rect((Screen.width*.5f)-250, 20.0f,500.0f,500.0f), currentGOInfo, bigStyle);
    	if(_active){
    	
    	
    	//Time Scale Vertical Slider
    	//Time.timeScale = GUI.VerticalSlider (Rect (185, 50, 20, 150), Time.timeScale, 2.0, 0.0);
    	//Field of view Vertical Slider
    		//Camera.mainCamera.fieldOfView = GUI.VerticalSlider (Rect (225, 50, 20, 150), Camera.mainCamera.fieldOfView, 20.0, 100.0);
    	//Check if there are more particle systems than max buttons (true adds "next" and "prev" buttons)
    	if(particles.Length > maxButtons){
    		//Prev button
    		if(GUI.Button(new Rect(20.0f,(float)((maxButtons+1)*18),75.0f,18.0f),"Prev"))if(page > 0)page--;else page=pages;
    		//Next button
    		if(GUI.Button(new Rect(95.0f,(float)((maxButtons+1)*18),75.0f,18.0f),"Next"))if(page < pages)page++;else page=0;
    		//Page text
    		GUI.Label (new Rect(60.0f,(float)((maxButtons+2)*18),150.0f,22.0f), "Page" + (page+1) + " / " + (pages+1));
    		
    	}
    	if(GUI.Button(new Rect(170.0f,(float)((maxButtons+1)*18),100.0f,18.0f),"Clear Bodies")){
    	
    	foreach(GameObject fooObj in GameObject.FindGameObjectsWithTag("Player"))
    		{		
        		if(fooObj != this.currentGO)
          		Destroy(fooObj);
       		 
    		}
    	
    	
    	}	
    	if(GUI.Button(new Rect(170.0f,(float)((maxButtons+2)*18),100.0f,18.0f),"Decapitate")){
    	
    		this.currentGO.GetComponent<ToonCharacterController>().Decapitate(false, 1.0f, Vector3.zero);
    	
    	
    	}
    	if(GUI.Button(new Rect(170.0f,(float)((maxButtons+3)*18),100.0f,18.0f),"Explode Head")){
    	
    		this.currentGO.GetComponent<ToonCharacterController>().Decapitate(true, 0.0f, new Vector3(3.0f,10.0f,3.0f));
    	
    	
    	}
    	if(GUI.Button(new Rect(170.0f,(float)((maxButtons+4)*18),100.0f,18.0f),"Blink Random")){
    	
    		this.currentGO.GetComponent<ToonCharacterController>().Blink(10, .05f);
    	
    	
    	}
    	if(GUI.Button(new Rect(170.0f,(float)((maxButtons+5)*18),100.0f,18.0f),"Blink White")){
    	
    		this.currentGO.GetComponent<ToonCharacterController>().Blink(10, .05f, 20.0f, 20.0f, 20.0f);
    	
    	
    	}
    	//Calculate how many buttons on current page (last page might have less)
    	int pageButtonCount = particles.Length - (page*maxButtons);
    	//Debug.Log(pageButtonCount);
    	if(pageButtonCount > maxButtons)pageButtonCount = maxButtons;
    	
    	//Adds buttons based on how many particle systems on page
    	for(int i=0;i < pageButtonCount;i++){
    		string buttonText = particles[i+(page*maxButtons)].transform.name;
    		if(removeTextFromButton != "")
    		buttonText = buttonText.Replace(removeTextFromButton, "");
    		if(GUI.Button(new Rect(20.0f,(float)(i*18+18),250.0f,18.0f),buttonText)){
    			if(currentGO != null){
    			StartCoroutine(this.currentGO.GetComponent<ToonCharacterController>().enableRagdoll(0.0f,new Vector3(3.0f,10.0f,3.0f)));
    			currentGO = null;
    			}
    			if(currentGO != null) Destroy(currentGO);
    			GameObject go = (GameObject)Instantiate(particles[i+page*maxButtons]);
    			currentGO = go;
    			counter = i + (page * maxButtons);
    			if(material != null)
    //			go.renderer.sharedMaterial = material;
    			Info(go,  i + (page * maxButtons) +1);
    		}
    	}
    
    	for(int m=0;m < materials.Length;m++){
    		string b = materials[m].name;
    		if(removeTextFromMaterialButton != "")
    			b = b.Replace(removeTextFromMaterialButton, "");
    		if(GUI.Button(new Rect(20.0f,(float)((1+m+4)*18),150.0f,18.0f),b)){
    			material = materials[m];
    			if(currentGO.GetComponent<Renderer>() != null){
    			currentGO.GetComponent<Renderer>().sharedMaterial = material;
    			}else{
    				
    				GameObject.Find("MicroMale").GetComponent<Renderer>().sharedMaterial = material;
    			
    			}
    		}
    	}
    	}
    	
   // 	if(image != null){
  //  			var tmp_cs1 = image.pixelInset;
  //              tmp_cs1.x = (float)((Screen.width) -(image.texture.width) );
   //             image.pixelInset = tmp_cs1;
    //		}
    }
    
    public void Info(GameObject go,int i) {
    	if(go.GetComponent<ParticleSystem>() != null){
    			PlayPS(go.GetComponent<ParticleSystem>(), i );
    			InfoPS(go.GetComponent<ParticleSystem>(), i );
    			}else{
    			//InfoGO(go, i);
    			}
    
    }
    
    public void ReplaceGO(GameObject _go){
    		if(currentGO != null) Destroy(currentGO);
    			GameObject go = (GameObject)Instantiate(_go);
    			currentGO = go;
    			if(material != null)
    			go.GetComponent<Renderer>().sharedMaterial = material;
    }
    
    //Play particle system (resets time scale)
    public void PlayPS(ParticleSystem _ps,int _nr){
    		Time.timeScale = 1.0f;
    		_ps.Play();
    		
    }
    
    public void InfoGO(GameObject _ps,int _nr){
    		currentGOInfo = "" + "" + _nr + "/" + particles.Length +"\n"+
    		_ps.gameObject.name +"\n" + _ps.GetComponent<MeshFilter>().sharedMesh.triangles.Length/3 + " Tris";
    		currentGOInfo = currentGOInfo.Replace("_", " ");
    		//Instructions();
    		
    }
    
    public void Instructions() {
    		currentGOInfo = currentGOInfo + "\n\nUse mouse wheel to zoom \n"+"Click and hold to rotate\n"+"Press Space to show or hide menu\n"+"Press Up and Down arrows to cycle materials\n"+"Press B to cycle background colors";
    			currentGOInfo = currentGOInfo.Replace("(Clone)", "");
    }
    
    public void InfoPS(ParticleSystem _ps,int _nr){
    		//Change current particle info text
    		currentGOInfo = "System" + ": " + _nr + "/" + particles.Length +"\n"+
    		"Name: " + _ps.gameObject.name +"\n\n" +
    		"Main PS Sub Particles: " + _ps.transform.childCount  +"\n" +
    		"Main PS Materials: " + _ps.GetComponent<Renderer>().materials.Length +"\n" +
    		"Main PS Shader: " + _ps.GetComponent<Renderer>().material.shader.name;
    		//If plasma(two materials)
    		if(_ps.GetComponent<Renderer>().materials.Length >= 2)currentGOInfo = currentGOInfo + "\n\n *Plasma not mobile optimized*";
    		//Instructions();
    }
}
