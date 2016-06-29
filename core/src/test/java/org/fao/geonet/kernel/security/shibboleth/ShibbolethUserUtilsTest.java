package org.fao.geonet.kernel.security.shibboleth;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import java.util.Set;

import javax.servlet.http.HttpServletRequest;

import org.fao.geonet.AbstractCoreIntegrationTest;
import org.fao.geonet.domain.Profile;
import org.fao.geonet.domain.User;
import org.fao.geonet.repository.UserRepository;
import org.junit.Test;
import org.springframework.beans.factory.annotation.Autowired;

/**
 * Tests for the ShibbolethUserUtils class.
 * 
 * @author Conny Nilimaa
 */
public class ShibbolethUserUtilsTest  extends AbstractCoreIntegrationTest{

    @Autowired
    private UserRepository _userRepo;

    /**
     * Test calling the setupUser method with an existing user but with a different profile.    
     * @throws Exception
     */
    @Test
    public void testDifferentProfile() throws Exception {
        
        User user = mockUser();
        user.setProfile(Profile.Reviewer);       
        _userRepo.saveAndFlush(user);
        
        ShibbolethUserUtils suu = new ShibbolethUserUtils();
        
        HttpServletRequest request = mockRequest();    
        ShibbolethUserConfiguration config = mockConfig();
        
        User setupUser = (User) suu.setupUser(request, config);
        
        // config doesn't update profile so it still should be Reviewer
        assertEquals(Profile.Reviewer, setupUser.getProfile());
        
        // now change config to allow updates, profile should change to Editor
        config.setUpdateProfile(true);

        setupUser = (User) suu.setupUser(request, config);
       
        assertUser(setupUser);        
        assertUser(_userRepo.findOneByUsername("myUsername"));
    }
    
    /**
     * Test calling the setupUser method with an existing user.
     * @throws Exception
     */
    @Test
    public void testExistingUser() throws Exception {

        long initialUserCount = _userRepo.count();
        
        User user = mockUser();
        _userRepo.saveAndFlush(user);
        
        assertEquals(initialUserCount + 1,  _userRepo.count());
        
        HttpServletRequest request = mockRequest();
        
        // change firstname header to verify that user is fetched from UserRepository
        when(request.getHeader("firstname")).thenReturn("notMyFirstname");
        
        ShibbolethUserConfiguration config = mockConfig();

        ShibbolethUserUtils suu = new ShibbolethUserUtils();
        User setupUser = (User) suu.setupUser(request, config);
        
        assertUser(setupUser);
        
        assertEquals(initialUserCount + 1,  _userRepo.count());
    }
    
    /**
     * Test calling the setupUser method with a new user.
     * The user should be created in the UserRepository.
     * @throws Exception
     */
    @Test
    public void testNewUser() throws Exception {

        long initialUserCount = _userRepo.count();
        
        HttpServletRequest request = mockRequest();
        ShibbolethUserConfiguration config = mockConfig();

        ShibbolethUserUtils suu = new ShibbolethUserUtils();

        User setupUser = (User) suu.setupUser(request, config);
        assertUser(setupUser);
       
        assertEquals(initialUserCount + 1,  _userRepo.count());

        User repoUser = _userRepo.findOneByUsername("myUsername");
        
        assertUser(repoUser);
    }
    
    private void assertUser(User user){
        assertNotNull(user);

        assertEquals("myUsername", user.getUsername());
        assertEquals("myFirstname", user.getName());
        assertEquals("mySurname", user.getSurname());
        assertEquals("myEmail@example.com", user.getEmail());
        
        Set<String> emailAddresses = user.getEmailAddresses();
        assertEquals(1, emailAddresses.size());
        
        String first = emailAddresses.iterator().next();
        assertEquals("myEmail@example.com", first);
        
        assertEquals(Profile.Editor, user.getProfile());
        
        //TODO test group
    }

    private ShibbolethUserConfiguration mockConfig() {
        ShibbolethUserConfiguration config = new ShibbolethUserConfiguration();

        config.setUsernameKey("username");
        config.setFirstnameKey("firstname");
        config.setSurnameKey("surname");
        config.setEmailKey("email");        
        config.setGroupKey("group");
        config.setProfileKey("profile");
        
        config.setUpdateGroup(false);
        config.setUpdateProfile(false);
        config.setDefaultGroup("defaultGroup");

        return config;
    }

    private HttpServletRequest mockRequest() {
        HttpServletRequest request = mock(HttpServletRequest.class);
        
        when(request.getHeader("username")).thenReturn("myUsername");
        when(request.getHeader("firstname")).thenReturn("myFirstname");
        when(request.getHeader("surname")).thenReturn("mySurname");
        when(request.getHeader("email")).thenReturn("myEmail@example.com");
        when(request.getHeader("group")).thenReturn("myGroup");
        when(request.getHeader("profile")).thenReturn("editor");
        
        return request;
    }
    
    private User mockUser(){
        User user = new User();        
        user.setUsername("myUsername");
        user.setName("myFirstname");
        user.setSurname("mySurname");
        user.setProfile(Profile.Editor);
        user.getEmailAddresses().add("myEmail@example.com");
        
        return user;
    }
}
