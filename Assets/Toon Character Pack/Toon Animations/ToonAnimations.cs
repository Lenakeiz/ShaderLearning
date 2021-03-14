using UnityEngine;
using System;
using System.Collections.Generic;
//using UnityEngine.Experimental.Director;


public class ToonAnimations:MonoBehaviour{
    	//Used to sort list
    public Animator _animator;
    public string[] _animations;
    public bool _crossFade;
    public int maxButtons = 10;			//Maximum buttons per page	
    
    public string removeTextFromButton;	//Unwanted text 
    public float autoChangeDelay;
  //  public GUITexture image;
    public string _lastAnim;
    int page = 0;			//Current page
    int pages;				//Number of pages
    
    bool _active = true;
   // int counter = -1;
    
    
    public void Start(){
    	//Sort list alphabeticly
        //_animations.Sort(_animations, function(g1,g2) String.Compare(g1, g2));
    	pages = (int)Mathf.Ceil((float)((_animations.Length -1 )/ maxButtons));	
    }
    
    public void OnGUI() {
    	if(_animator == null)
    	_animator = (Animator)Transform.FindObjectOfType(typeof(Animator));
    	if(_active){
    	//Time Scale Vertical Slider
    	//Time.timeScale = GUI.VerticalSlider (Rect (185, 50, 20, 150), Time.timeScale, 2.0, 0.0);
    	//Check if there are more in list than max buttons (true adds "next" and "prev" buttons)
    	if(_animations.Length > maxButtons){
    		//Prev button
    		if(GUI.Button(new Rect(20.0f,(float)((maxButtons+1)*18),75.0f,18.0f),"Prev"))if(page > 0)page--;else page=pages;
    		//Next button
    		if(GUI.Button(new Rect(95.0f,(float)((maxButtons+1)*18),75.0f,18.0f),"Next"))if(page < pages)page++;else page=0;
    		//Page text
    		GUI.Label (new Rect(60.0f,(float)((maxButtons+2)*18),150.0f,22.0f), "Page" + (page+1) + " / " + (pages+1));
    	}
    	//Calculate how many buttons on current page (last page might have less)
    	int pageButtonCount = _animations.Length - (page*maxButtons);
    	//Debug.Log(pageButtonCount);
    	if(pageButtonCount > maxButtons)pageButtonCount = maxButtons;
    	//Adds buttons based on how many particle systems on page
    	for(int i=0;i < pageButtonCount;i++){
    		string buttonText = _animations[i+(page*maxButtons)];
    		if(removeTextFromButton != "")
    		buttonText = buttonText.Replace(removeTextFromButton, "");
    		if(GUI.Button(new Rect(20.0f,(float)(i*18+18),150.0f,18.0f),buttonText)){
    			if(_crossFade){	
    			if(_lastAnim == (_animations[i+page*maxButtons]))
    			this._animator.Play("");
    			_animator.CrossFade(_animations[i+page*maxButtons], .1f);
    			this._lastAnim = _animations[i+page*maxButtons];
    			}else{
    			
    			_animator.Play(_animations[i+page*maxButtons]);
    			}
  //  			counter = i + (page * maxButtons);	
    		}
    	}
    	}
    //	if(image != null){
    //			var tmp_cs1 = image.pixelInset;
    //            tmp_cs1.x = (float)((Screen.width) -(image.texture.width) );
     //           image.pixelInset = tmp_cs1;
    //		}
    }
}