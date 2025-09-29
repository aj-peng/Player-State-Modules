# Player-State-Modules
**ActionState**: A customizable module for controlling the player's action states.  
- Features:
  - Priority Hierarchy: Higher priority actions can interrupt lower priority ones
  - Timed Action Locks: Actions can lock the system for a specific duration
  - Action Queue: Support for queuing actions when the system is locked
  - State Inspection: Get current action state and locking status

**StateManager**: A customizable module for managing and synchronizing humanoid states across client and server.  
- Features:
  - Bi-directional State Synchronization: Automatic state sync between client and server
  - Type-Safe State Management: Strict typing for reliable state structure
  - Automatic Cleanup: Proper connection management and cleanup
