# Stopping the Motion Service

## Steps

1. **Find the motion process:**
   
   Execute the following command to find the motion process.
   ```bash
   ps aux | grep motion | grep -v grep
   ```
   
   Note the process ID (PID) of the motion service.

2. **Kill the motion process:**

   Use the `kill` command with `sudo` to stop the process. Replace `<PID>` with the process ID you found.
   ```bash
   sudo kill <PID>
   ```
   
   If a stronger force is necessary:
   ```bash
   sudo kill -9 <PID>
   ```
   
3. **Verify that the motion process has stopped:**

   Run the command again to check if the motion service is still active.
   ```bash
   ps aux | grep motion | grep -v grep
   ```

   If there is no output, the motion service has stopped successfully.

## Notes
- Make sure you have the necessary permissions to run these commands.
- Replace `<PID>` with the actual PID of the motion process.

