/****************************************
	DecapitatedHead.js
	Adds some force to the head and disables the rigidbodies kinematic
	
	Copyright 2013 Unluck Software	
 	www.chemicalbliss.com											
*****************************************/

using UnityEngine;
using System;
using System.Collections;


public class DecaptitatedHead:MonoBehaviour
{
    public Vector3 force;
    public float delay = 0.25f;
    public IEnumerator Start() {
    	yield return new WaitForSeconds(delay);
    	GetComponent<Rigidbody>().isKinematic = false;
    	GetComponent<Rigidbody>().AddForce(force*UnityEngine.Random.value);
    	GetComponent<Rigidbody>().AddTorque(new Vector3((float)UnityEngine.Random.Range(-1, 1),(float)UnityEngine.Random.Range(-1, 1),(float)UnityEngine.Random.Range(-1, 1)));
    }
}