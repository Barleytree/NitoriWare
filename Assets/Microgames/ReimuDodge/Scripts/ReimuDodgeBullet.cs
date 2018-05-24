using System.Collections;
using UnityEngine;

public class ReimuDodgeBullet : MonoBehaviour
{

    [Header("How fast the bullet goes")]
    [SerializeField]
    private float speed;

    [Header("Firing delay in seconds")]
    [SerializeField]
    private float delay;

    // Stores the direction of travel for the bullet
    private Vector2 trajectory;

    // Use this for initialization
    void Start()
    {
        // Wait before targetting the player
        this.StartCoroutine(Wait(this.delay));
    }
    
    // Update is called once per frame
    void Update()
    {
        // Only start moving after the trajectory has been set
        if (this.trajectory != null)
        {
            // Move the bullet a certain distance based on trajectory speed and time
            Vector2 newPosition = (Vector2)this.transform.position + (this.trajectory * this.speed * Time.deltaTime);
            this.transform.position = newPosition;
        }
    }

    void SetTrajectory()
    {
        // Find the player object in the scene and calculate a trajectory towards them
        GameObject player = GameObject.Find("Player");
        this.trajectory = (player.transform.position - this.transform.position).normalized;
    }
    
    IEnumerator Wait(float seconds)
    {
        yield return new WaitForSeconds(seconds);

        // Acquire target
        this.SetTrajectory();
    }
    
}
