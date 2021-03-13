using UnityEngine;
using System.Collections;

public class CameraControl : MonoBehaviour
{
	GameObject defaultCam;
	Vector2 _mouseAbsolute;
	Vector2 _smoothMouse;

	public float fastSpeed = 0.6f;
	public float cameraSpeed = .2f;
	public float defaultSpeed = .2f;

	public Vector2 clampInDegrees = new Vector2(360, 180);
	public bool lockCursor;
	public Vector2 sensitivity = new Vector2(2, 2);
	public Vector2 smoothing = new Vector2(3, 3);
	public Vector2 targetDirection;

	private Transform target;
	public float distance = 3.0f;
	public float height = 3.0f;
	public float heightOffset = 1f;
	public float damping = 5.0f;
	public bool smoothRotation = true;
	public float rotationDamping = 10.0f;
	
	void Start()
	{
		defaultSpeed = cameraSpeed;
		targetDirection = transform.localRotation.eulerAngles;
		defaultCam = this.gameObject;
	}
	
	void Update()
	{
		if(Input.GetKey(KeyCode.W))
		{
			defaultCam.transform.position += cameraSpeed * transform.forward;
		}

		if(Input.GetKey(KeyCode.S))
		{
			defaultCam.transform.position += cameraSpeed * -transform.forward;
		}

		if(Input.GetKey(KeyCode.A))
		{
			defaultCam.transform.position += cameraSpeed * -transform.right;
		}

		if(Input.GetKey(KeyCode.D))
		{
			defaultCam.transform.position += cameraSpeed * transform.right;
		}

		if(Input.GetKey(KeyCode.E))
		{
			defaultCam.transform.position += cameraSpeed * Vector3.up;
		}

		if(Input.GetKey(KeyCode.Q))
		{
			defaultCam.transform.position += cameraSpeed * -Vector3.up;
		}
		
		if(Input.GetKey(KeyCode.LeftShift))
		{
			cameraSpeed = fastSpeed;
		}
		else
		{
			cameraSpeed = defaultSpeed;
		}

		if(Input.GetButton("Fire1"))
		{
			//Ensure the cursor is always locked when set.
			Cursor.lockState = CursorLockMode.Locked;
			
			//Allow the script to clamp based on a desired target value.
			Quaternion targetOrientation = Quaternion.Euler(targetDirection);
			
			//Get raw mouse input for a cleaner reading on more sensitive mice.
			Vector2 mouseDelta = new Vector2(Input.GetAxisRaw("Mouse X"), Input.GetAxisRaw("Mouse Y"));
			
			//Scale input against the sensitivity setting and multiply that against the smoothing value.
			mouseDelta = Vector2.Scale(mouseDelta, new Vector2(sensitivity.x * smoothing.x, sensitivity.y * smoothing.y));
			
			//Interpolate mouse movement over time to apply smoothing delta.
			_smoothMouse.x = Mathf.Lerp(_smoothMouse.x, mouseDelta.x, 1f / smoothing.x);
			_smoothMouse.y = Mathf.Lerp(_smoothMouse.y, mouseDelta.y, 1f / smoothing.y);
			
			//Find the absolute mouse movement value from point zero.
			_mouseAbsolute += _smoothMouse;

			//Clamp and apply the local x value first, so as not to be affected by world transforms.
			if(clampInDegrees.x < 360)
			{
				_mouseAbsolute.x = Mathf.Clamp(_mouseAbsolute.x, -clampInDegrees.x * 0.5f, clampInDegrees.x * 0.5f);
			}
			
			Quaternion xRotation = Quaternion.AngleAxis(-_mouseAbsolute.y, targetOrientation * Vector3.right);
			transform.localRotation = xRotation;

			//Then clamp and apply the global y value.
			if(clampInDegrees.y < 360)
			{
				_mouseAbsolute.y = Mathf.Clamp(_mouseAbsolute.y, -clampInDegrees.y * 0.5f, clampInDegrees.y * 0.5f);
			}
			
			transform.localRotation *= targetOrientation;
			
			Quaternion yRotation = Quaternion.AngleAxis(_mouseAbsolute.x, transform.InverseTransformDirection(Vector3.up));
			transform.localRotation *= yRotation;
		}
	}
}