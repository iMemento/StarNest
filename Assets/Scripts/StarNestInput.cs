using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class StarNestInput : MonoBehaviour
{
    private Vector3 lastMousePosition;
    private MeshRenderer mr;
    void Start()
    {
        mr = GetComponent<MeshRenderer>();
    }


    private Vector2 mouse;
    void Update()
    {
        if (Input.GetMouseButtonDown(0))
        {
            lastMousePosition = Input.mousePosition;
        }
        
        if (Input.GetMouseButtonUp(0))
        {
            var delta = (Input.mousePosition - lastMousePosition) / 10000f;
            mouse.x += delta.x;
            mouse.y += delta.y;
            mr.material.SetVector("_iMouse", new Vector4(mouse.x, mouse.y, 0f, 0f));
        }
    }
}
