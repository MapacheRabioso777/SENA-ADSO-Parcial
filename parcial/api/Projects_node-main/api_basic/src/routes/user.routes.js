/**
*Author: 	DIEGO CASALLAS
*Date:		01/01/2026   
*Description: Routes for user management — POST /user is public (registration), GET requires token.
**/
import { Router } from 'express';
import { showUser, showUserId, addUser, updateUser, deleteUser, loginUser } from '../controllers/user.controller.js';
import { verifyToken } from '../middleware/authMiddleware.js';

const router = Router();
const apiName = '/user';

router.route(apiName)
  .get(verifyToken, showUser)  // Get all users — protected
  .post(addUser);              // Register new user — PUBLIC (no token required)

router.route('/userLogin')
  .post(loginUser);            // Login for users table — PUBLIC

router.route(`${apiName}/:id`)
  .get(verifyToken, showUserId)    // Get user by Id
  .put(verifyToken, updateUser)    // Update user by Id
  .delete(verifyToken, deleteUser); // Delete user by Id

export default router;