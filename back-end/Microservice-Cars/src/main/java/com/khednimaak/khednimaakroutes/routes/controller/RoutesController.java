package com.khednimaak.khednimaakroutes.routes.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.RestTemplate;

import com.khednimaak.khednimaakroutes.routes.entity.Routes;
import com.khednimaak.khednimaakroutes.routes.service.RoutesService;

import reactor.core.publisher.Mono;




@RestController
public class RoutesController {
	@Autowired
	private RoutesService service;
	
	
	
    @GetMapping("/routes")
    public List<Routes> findAllCars() {
        return service.getRoutes();
    }

    @GetMapping("/routes/{id}")
    public Routes findCarById(@PathVariable int id) {
        return service.getRouteById(id);
    }
    
	@PostMapping("/addRoute")
	public Routes addRoute(@RequestBody Routes route) {
		return service.saveRoute(route);  
	}
   
    
}
