import Vue from 'vue'
import Router from 'vue-router'
import index from '@/components/index'
// import Login from '@/views/Login'

Vue.use(Router)

export default new Router({
  routes: [
    {
      path: '/',
      name: 'index',
      component: index
    },
  ],
//   mode: 'hash'
})
