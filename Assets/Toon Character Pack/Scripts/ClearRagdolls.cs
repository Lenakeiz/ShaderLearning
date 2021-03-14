//Script to remove ragdolls when they reach a max amount (not optimized)

using UnityEngine;

public class ClearRagdolls:MonoBehaviour{
    public int maxRagdolls;
    public GameObject rag;
    public void Start() {
    	InvokeRepeating("ClearRags", 1.0f,1.0f);
    }
    
    public void ClearRags() {
    
    	
    	int counter = 0;
    	foreach(GameObject fooObj in GameObject.FindGameObjectsWithTag("Player"))
    		{		
        		if(fooObj.GetComponent<Rigidbody>().useGravity==true){
        		if(rag == null)
          		rag = fooObj;
          		counter++;
          		}
    		}
    	if(maxRagdolls < counter){
    		Destroy(rag);
    	}
    }
}