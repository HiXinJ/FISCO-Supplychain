<template>
  <div id="app">

    <!-- <img alt="Vue logo" src="./assets/logo.png"> -->

 <el-menu>
    <h1 id="SimpleBlog">Simple Blog</h1>
    <el-menu-item index="/" >主页</el-menu-item>
  </el-menu>
    <!--<img src="./assets/logo.png">-->
    <router-view/>

    <!-- <HelloWorld msg="Wesssslcome to Your Vue.js App"/> -->
  </div>
</template>

<script>
// import HelloWorld from './components/HelloWorld.vue'

export default {
  name: 'app',
}
</script>

<style>
#app {
  font-family: 'Avenir', Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
  margin-top: 60px;
}
</style>
